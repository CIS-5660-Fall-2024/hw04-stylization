// This Unity shader reconstructs the world space positions for pixels using a depth
// texture and screen space UV coordinates. The shader draws a checkerboard pattern
// on a mesh to visualize the positions.
Shader "Custom/Grass"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}  
        
        [Header(Tess)][Space]
     
        [KeywordEnum(integer, fractional_even, fractional_odd)]_Partitioning ("Partitioning Mode", Float) = 2
        [KeywordEnum(triangle_cw, triangle_ccw)]_Outputtopology ("Outputtopology Mode", Float) = 0
        [IntRange]_EdgeFactor ("EdgeFactor", Range(1,20)) = 20
        _TessMinDist ("TessMinDist", Range(0,50)) = 30.0
        _FadeDist ("FadeDist", Range(1,500)) = 200.0
        _HeightScale ("HeightScale", Range(1,50)) = 10.0
        _LandSpread ("LandSpread", Range(0.01, 0.1)) = 0.02
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
         
        Pass
        { 
            HLSLPROGRAM
            #pragma target 4.6 
            #pragma vertex DistanceBasedTessVert
            #pragma fragment DistanceBasedTessFrag 
            #pragma hull DistanceBasedTessControlPoint
            #pragma domain DistanceBasedTessDomain
             
            #pragma multi_compile _PARTITIONING_INTEGER _PARTITIONING_FRACTIONAL_EVEN _PARTITIONING_FRACTIONAL_ODD 
            #pragma multi_compile _OUTPUTTOPOLOGY_TRIANGLE_CW _OUTPUTTOPOLOGY_TRIANGLE_CCW 

 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GeometricTools.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Tessellation.hlsl"
            #include "Assets/Shaders/Common.hlsl"
            CBUFFER_START(UnityPerMaterial) 
            float _EdgeFactor;  
            float _TessMinDist;
            float _FadeDist;
            float _HeightScale;
            float _LandSpread;
            CBUFFER_END

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap); 

            struct Attributes
            {
                float3 positionOS   : POSITION; 
                float2 texcoord     : TEXCOORD0;
    
            };

            struct VertexOut{
                float3 positionWS : INTERNALTESSPOS; 
                float2 texcoord : TEXCOORD0;
            };
             
            struct PatchTess {  
                float edgeFactor[3] : SV_TESSFACTOR;
                float insideFactor  : SV_INSIDETESSFACTOR;
            };

            struct HullOut{
                float3 positionWS : INTERNALTESSPOS; 
                float2 texcoord : TEXCOORD0;
            };

            struct DomainOut
            {
                float4 positionCS      : SV_POSITION;
                float2 texcoord        : TEXCOORD0; 
                float3 positionWS      : TEXCOORD1;
                float3 normal          : TEXCOORD2;
            };

            float h(float2 xz, float amp)
            {
                float height = fbmPerlin(xz, 0.5, 0.5, 3);
                height = smoothstep(0.0, 1.0, height) * 0.8 + 0.2 * height;
                return height * amp;
            }

            VertexOut DistanceBasedTessVert(Attributes input){ 
                VertexOut o;
                o.positionWS = TransformObjectToWorld(input.positionOS);  
                o.texcoord   = input.texcoord;
                return o;
            }
   
   
            PatchTess PatchConstant (InputPatch<VertexOut,3> patch, uint patchID : SV_PrimitiveID){ 
                PatchTess o;
                float3 cameraPosWS = GetCameraPositionWS();
                real3 triVectexFactors =  GetDistanceBasedTessFactor(patch[0].positionWS, patch[1].positionWS, patch[2].positionWS, cameraPosWS, _TessMinDist, _TessMinDist + _FadeDist);
 
                float4 tessFactors = _EdgeFactor * CalcTriTessFactorsFromEdgeTessFactors(triVectexFactors);
                o.edgeFactor[0] = max(1.0, tessFactors.x);
                o.edgeFactor[1] = max(1.0, tessFactors.y);
                o.edgeFactor[2] = max(1.0, tessFactors.z);

                o.insideFactor  = max(1.0, tessFactors.w);
                return o;
            }
 
            [domain("tri")]   
            #if _PARTITIONING_INTEGER
            [partitioning("integer")] 
            #elif _PARTITIONING_FRACTIONAL_EVEN
            [partitioning("fractional_even")] 
            #elif _PARTITIONING_FRACTIONAL_ODD
            [partitioning("fractional_odd")]    
            #endif 
 
            #if _OUTPUTTOPOLOGY_TRIANGLE_CW
            [outputtopology("triangle_cw")] 
            #elif _OUTPUTTOPOLOGY_TRIANGLE_CCW
            [outputtopology("triangle_ccw")] 
            #endif

            [patchconstantfunc("PatchConstant")] 
            [outputcontrolpoints(3)]                 
            [maxtessfactor(64.0f)]                 
            HullOut DistanceBasedTessControlPoint (InputPatch<VertexOut,3> patch,uint id : SV_OutputControlPointID){  
                HullOut o;
                o.positionWS = patch[id].positionWS;
                o.texcoord = patch[id].texcoord; 
                return o;
            }
 
  
            [domain("tri")]      
            DomainOut DistanceBasedTessDomain (PatchTess tessFactors, const OutputPatch<HullOut,3> patch, float3 bary : SV_DOMAINLOCATION)
            {  
                float3 positionWS = patch[0].positionWS * bary.x + patch[1].positionWS * bary.y + patch[2].positionWS * bary.z; 
	            float2 texcoord   = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
                float2 xz = positionWS.xz * _LandSpread;
                float heightScale = _HeightScale;
                float height = h(xz, heightScale);
                positionWS.y += height;
                float heightR = h(float2(xz.x + 0.01, xz.y), heightScale);
                float heightU = h(float2(xz.x, xz.y + 0.01), heightScale);
                float3 normal = normalize(cross(float3(0, heightU - height, 0.01), float3(0.01, heightR - height, 0)));

                DomainOut output;
                output.positionCS = TransformWorldToHClip(positionWS);
                output.texcoord = texcoord;
                output.positionWS = positionWS;
                output.normal = normal;
    
                return output; 
            }
 

            half4 DistanceBasedTessFrag(DomainOut input) : SV_Target{   
                half3 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.texcoord).rgb;
                color = (h(input.positionWS.xz * _LandSpread, 1.0) + 1.0) / 2.0;
                // color = input.normal * 0.5 + 0.5;
                return half4(color, 1.0); 
            }


            ENDHLSL
        }
    }
}
