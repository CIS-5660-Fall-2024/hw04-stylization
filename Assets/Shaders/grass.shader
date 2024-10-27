Shader "Custom/Grass"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}  
        _WindMap ("Wind Map", 2D) = "white" {}

        [HideInInspector] [KeywordEnum(integer, fractional_even, fractional_odd)]_Partitioning ("Partitioning Mode", Float) = 2
        [HideInInspector] [KeywordEnum(triangle_cw, triangle_ccw)]_Outputtopology ("Outputtopology Mode", Float) = 0
        [Header(Tess)][Space]
        [IntRange]_EdgeFactor ("EdgeFactor", Range(1,20)) = 20
         _TessMinDist ("TessMinDist", Range(0,1000)) = 1000.0
         _FadeDist ("FadeDist", Range(1,1000)) = 1000.0
        _HeightScale ("HeightScale", Range(1,50)) = 10.0
        _LandSpread ("LandSpread", Range(0.01, 0.3)) = 0.1

        [Header(Grass Spec)][Space]
        _Width ("Width", Range(0.1, 2.0)) = 0.5
        _Height ("Height", Range(0.1, 5.0)) = 4.0

        _PosJitter ("PosJitter", Range(0.01, 2.0)) = 0.05
        _WidthJitter ("WidthJitter", Range(0.0, 0.8)) = 0.5
        _HeightJitter ("HeightJitter", Range(0.0, 0.8)) = 0.5
        _RotationJitter ("RotationJitter", Range(0.0, 0.8)) = 0.5
        _DirectionJitter ("DirectionJitter", Range(0.0, 0.8)) = 0.5

        _InteractiveRadius ("InteractiveRadius", Range(0.1, 10.0)) = 1.0
        [Header(Grass Tess)][Space]
        _GrassTessMinDist ("GrassTessMinDist", Range(0,200)) = 100.0
        _GrassFadeDist ("GrassFadeDist", Range(1,300)) = 200.0

        [Header(Wind)][Space]
        _WindSpeed ("Wind Speed", Range(0, 1)) = 0.5
        _WindStrength ("Wind Strength", Range(0, 5)) = 0.5
    }
    SubShader
    {
        Cull Off
        HLSLINCLUDE
        #include "Assets/Shaders/GrassCommon.hlsl"
        CBUFFER_START(GrassMaterial)
        float _Width;
        float _Height;

        float _PosJitter;
        float _WidthJitter;
        float _HeightJitter;
        float _RotationJitter;
        float _DirectionJitter;
        float _InteractiveRadius;

        float _GrassTessMinDist;
        float _GrassFadeDist;

        float _WindSpeed;
        float _WindStrength;
        CBUFFER_END

        
        TEXTURE2D(_WindMap); 
        SAMPLER(sampler_WindMap);
        float4 _WindMap_ST;

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
            float heightR = h(float2(xz.x + 0.01 * _LandSpread, xz.y), heightScale);
            float heightU = h(float2(xz.x, xz.y + 0.01 * _LandSpread), heightScale);
            float3 normal = normalize(cross(float3(0, heightU - height, 0.01), float3(0.01, heightR - height, 0)));

            DomainOut output;
            output.positionCS = TransformWorldToHClip(positionWS);
            output.texcoord = texcoord;
            output.positionWS = positionWS;
            output.normal = normal;
            return output; 
        }

        GeometryOut generateVertex(float3 positionWS, float2 texcoord, float3 grassPos, float3 normal)
        {
            GeometryOut output;
            output.positionCS = TransformWorldToHClip(positionWS);
            output.texcoord = texcoord;
            output.positionWS = positionWS;
            output.normal = normal;
            output.rootPos = grassPos;
            return output;
        }

        #define MAXSEGMENT 15
        [maxvertexcount(MAXSEGMENT * 2 + 1)]
        void GrassGeometryShader(triangle DomainOut input[3], inout TriangleStream<GeometryOut> triStream)
        {
            float3 positionWS = (input[0].positionWS + input[1].positionWS + input[2].positionWS) / 3.0;
            float3 normalWS = (input[0].normal + input[1].normal + input[2].normal) / 3.0;
            float2 hash = hash22(positionWS.xz);
            float2 nhash = normalize(hash);
            float3 camPos = GetCameraPositionWS();
            float3x3 ltw = localToWorld(normalWS);

            // random width
            float width = _Width * length(lerp(nhash, hash, _WidthJitter));

            // random rotation
            float2 dir = normalize(lerp(float2(1, 0), nhash, _RotationJitter));
            float3 offset = 0;
            offset.xy = dir * width;
            offset = mul(ltw, offset);

            // random height
            float height = _Height * lerp(1, hash.x  + 1.0, _HeightJitter);
            float3 heightOffset = normalize(normalWS) * height;

            // random direction
            heightOffset = rotatePointAroundAxis(heightOffset, normalize(offset), abs(hash.y) * PI_HALF * _DirectionJitter);

            // wind 
            float2 windSample = SAMPLE_TEXTURE2D_LOD(_WindMap, sampler_WindMap, (positionWS.xz + 114.514) / (10.0 * _WindMap_ST.xy) + _WindMap_ST.zw, 0).rg * _WindMap_ST.xy * _WindStrength * 3.0;

            float phase0 = frac(_Time.y * _WindSpeed + 0.5);
            float phase1 = frac(_Time.y * _WindSpeed + 1.0);

            float3 wind0 = SAMPLE_TEXTURE2D_LOD(_WindMap, sampler_WindMap, (positionWS.xz + windSample * phase0) / (10.0 * _WindMap_ST.xy) + _WindMap_ST.zw, 0).rgb - 0.25;
            float3 wind1 = SAMPLE_TEXTURE2D_LOD(_WindMap, sampler_WindMap, (positionWS.xz + windSample * phase1) / (10.0 * _WindMap_ST.xy) + _WindMap_ST.zw, 0).rgb - 0.25;
            float flowLerp = abs((0.5 - phase0) / 0.5);
            float3 wind = lerp(wind0, wind1, flowLerp) * _WindStrength;
            wind.yz = wind.zy;

            // random position
            float2 jitter = hash * _PosJitter;
            float3 positionJT = (input[0].positionWS * jitter.x + input[1].positionWS * jitter.y + input[2].positionWS * (1 - jitter.x - jitter.y));
            float3 pos1 = positionJT + offset;
            float3 pos2 = positionJT - offset;
            float3 pos3 = positionJT + heightOffset;
            float3 normal = normalize(cross(pos2 - pos1, pos3 - pos1));

            float dist = distance(camPos, positionJT);

            int segment = (int)floor(lerp(MAXSEGMENT, 2, saturate((dist - _GrassTessMinDist) / _GrassFadeDist)));

            for (int i = 0; i < segment; i++)
            {
                float t = i / (float)segment;
                float heightAtten = t * t;
                float3 windOffset = wind * t;
                windOffset.y = -length(windOffset.xz)*0.05;
                
                // first vertex
                float3 posWS = positionJT + offset * (1 - t) + heightOffset * t * float3(t, 1, t) + windOffset;
                float2 texcoord = float2(t * 0.5, t);
                triStream.Append(generateVertex(posWS, texcoord, positionJT, normal));

                // second vertex
                posWS = positionJT - offset * (1 - t) + heightOffset * t *  float3(t, 1, t) + windOffset;
                texcoord = float2(1.0 - 0.5 * t, t);
                triStream.Append(generateVertex(posWS, texcoord, positionJT, normal));
            }
            float3 windOffset = wind;
            windOffset.y = -length(windOffset.xz)*0.1;
            triStream.Append(generateVertex(positionJT + heightOffset + windOffset , float2(0.5, 1), positionJT, normal));
        }

        half4 DistanceBasedTessFrag_Grass(GeometryOut input) : SV_Target{   
            half3 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.rootPos.xz / (10.0 * _BaseMap_ST.xy) + _BaseMap_ST.zw).rgb;
            float t = smoothstep(0, 1.0, input.texcoord.y) * 0.7 + 0.3;
            Light light = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
            

            return half4(color * t * light.color * light.distanceAttenuation * light.shadowAttenuation, 1.0); 
        }
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
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT//柔化阴影，得到软阴影

            ENDHLSL
        }

        // Pass
        // { 
        //     Name "Grass ShadowCaster"
        //     Tags { "LightMode" = "ShadowCaster"}
        //     ZWrite On
        //     ZTest LEqual

        //     HLSLPROGRAM
        //     #pragma target 4.6 
        //     #pragma vertex DistanceBasedTessVert
        //     #pragma fragment ShadowCasterFragment 
        //     #pragma hull DistanceBasedTessControlPoint
        //     #pragma domain DistanceBasedTessDomain_Grass
        //     #pragma geometry GrassGeometryShader // 添加Geometry Shader指令
        //     #pragma multi_compile _PARTITIONING_INTEGER _PARTITIONING_FRACTIONAL_EVEN _PARTITIONING_FRACTIONAL_ODD 
        //     #pragma multi_compile _OUTPUTTOPOLOGY_TRIANGLE_CW _OUTPUTTOPOLOGY_TRIANGLE_CCW 
            
        //     half4 ShadowCasterFragment(GeometryOut input) : SV_Target
        //     {
        //         return 0;
        //     }
        //     ENDHLSL
        // }
    }
}
