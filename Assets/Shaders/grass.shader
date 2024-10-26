Shader "Custom/Grass"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}  
        
        [Header(Tess)][Space]
     
        [KeywordEnum(integer, fractional_even, fractional_odd)]_Partitioning ("Partitioning Mode", Float) = 2
        [KeywordEnum(triangle_cw, triangle_ccw)]_Outputtopology ("Outputtopology Mode", Float) = 0
        [IntRange]_EdgeFactor ("EdgeFactor", Range(1,20)) = 20
        _TessMinDist ("TessMinDist", Range(0,100)) = 30.0
        _FadeDist ("FadeDist", Range(1,500)) = 200.0
        _HeightScale ("HeightScale", Range(1,50)) = 10.0
        _LandSpread ("LandSpread", Range(0.01, 0.1)) = 0.02
    }
    SubShader
    {
        Cull Off
        HLSLINCLUDE
        #include "Assets/Shaders/GrassCommon.hlsl"
        ENDHLSL
        Pass
        { 
            Name "Grass"
            Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "Queue"="Geometry+1"}
            HLSLPROGRAM
            #pragma target 4.6 
            #pragma vertex DistanceBasedTessVert
            #pragma fragment DistanceBasedTessFrag_Grass 
            #pragma hull DistanceBasedTessControlPoint
            #pragma domain DistanceBasedTessDomain_Grass
            #pragma geometry GrassGeometryShader // 添加Geometry Shader指令
            #pragma multi_compile _PARTITIONING_INTEGER _PARTITIONING_FRACTIONAL_EVEN _PARTITIONING_FRACTIONAL_ODD 
            #pragma multi_compile _OUTPUTTOPOLOGY_TRIANGLE_CW _OUTPUTTOPOLOGY_TRIANGLE_CCW 
            
            PatchTess PatchConstant (InputPatch<VertexOut,3> patch, uint patchID : SV_PrimitiveID){ 
                PatchTess o;
                float3 cameraPosWS = GetCameraPositionWS();
                real3 triVectexFactors = GetDistanceBasedTessFactor(patch[0].positionWS, patch[1].positionWS, patch[2].positionWS, cameraPosWS, _TessMinDist, _TessMinDist + _FadeDist);

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

            // Grass tesselation domain shader, fixed tessellation factors
            [domain("tri")]      
            DomainOut DistanceBasedTessDomain_Grass (PatchTess tessFactors, const OutputPatch<HullOut,3> patch, float3 bary : SV_DOMAINLOCATION)
            {  
                float3 positionWS = patch[0].positionWS * bary.x + patch[1].positionWS * bary.y + patch[2].positionWS * bary.z; 
                float2 texcoord   = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
                float2 xz = positionWS.xz * _LandSpread;
                float heightScale = _HeightScale;
                float height = h(xz, heightScale);
                positionWS.y += height;

                DomainOut output;
                output.positionCS = TransformWorldToHClip(positionWS);
                output.texcoord = texcoord;
                output.positionWS = positionWS;
                output.normal = float3(0, 1, 0);
                return output; 
            }

            [maxvertexcount(3)]
            void GrassGeometryShader(triangle DomainOut input[3], inout TriangleStream<GeometryOut> triStream)
            {
                float3 positionWS = (input[0].positionWS + input[1].positionWS + input[2].positionWS) / 3.0;
                float3 pos1 = positionWS + float3(-0.5, 0, 0);
                float3 pos2 = positionWS + float3(0.5, 0, 0);
                float3 pos3 = positionWS + float3(0, 2.0, 0);
                float3 normal = normalize(cross(pos2 - pos1, pos3 - pos1));
                GeometryOut output;
                output.positionCS = TransformWorldToHClip(pos1);
                output.texcoord = float2(0, 0);
                output.positionWS = positionWS;
                output.normal = normal;
                triStream.Append(output);

                output.positionCS = TransformWorldToHClip(pos2);
                output.texcoord = float2(1, 0);
                output.positionWS = positionWS;
                output.normal = normal;
                triStream.Append(output);

                output.positionCS = TransformWorldToHClip(pos3);
                output.texcoord = float2(0.5, 1);
                output.positionWS = positionWS;
                output.normal = normal;
                triStream.Append(output);
            }

            half4 DistanceBasedTessFrag_Grass(GeometryOut input) : SV_Target{   
                half3 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.positionWS.xz / (10.0 * _BaseMap_ST.xy) + _BaseMap_ST.zw).rgb;
                return half4(color, 1.0); 
            }

            ENDHLSL
        }
    }
}
