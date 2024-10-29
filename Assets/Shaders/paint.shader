// This Unity shader reconstructs the world space positions for pixels using a depth
// texture and screen space UV coordinates. The shader draws a checkerboard pattern
// on a mesh to visualize the positions.
Shader "Custom/Paint"
{
    Properties
    { 
        _BrushCube ("Brush Cube", CUBE) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _BrushFrequency ("Brush Frequency", Range(0.1, 10)) = 0.5
        _FactorFbm ("Factor Fbm", Range(0, 1)) = 0.5
        _FactorBrush ("Factor Brush", Range(0, 1)) = 0.5
    }

    // The SubShader block containing the Shader code.
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue"="Geometry+1"}
        // Blend SrcAlpha OneMinusSrcAlpha
        // Cull Front
        // ZWrite Off
        // ZTest Off

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Assets/Shaders/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float _BrushFrequency;
        float _FactorFbm;
        float _FactorBrush;
        CBUFFER_END


        TEXTURECUBE(_BrushCube);
        SAMPLER(sampler_BrushCube);

        struct Attributes
        {
            float4 positionOS   : POSITION;
            float2 uv : TEXCOORD0;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
        };

        struct Varyings
        {
            float4 positionHCS  : SV_POSITION;
            float3 positionWS : TEXCOORD0;
            float3 positionOS : TEXCOORD1;
            float2 uv : TEXCOORD2;
            float3 normal : TEXCOORD3;
            float3 normalOS : TEXCOORD4;
        };

        Varyings vert(Attributes IN)
        {
            Varyings OUT;
            VertexPositionInputs vertexInput = GetVertexPositionInputs(IN.positionOS.xyz);
            OUT.positionHCS = vertexInput.positionCS;
            OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
            OUT.positionOS = IN.positionOS.xyz;
            OUT.uv = IN.uv;
            
            VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normal, IN.tangent);
            OUT.normal = normalInput.normalWS;
            OUT.normalOS = IN.normal;
            return OUT;
        }

        half4 frag(Varyings IN) : SV_Target
        {
            float3 normal = IN.normal;
            // float3 sampledNormal = SAMPLE_TEXTURE2D(_BrushMap, sampler_BrushMap, IN.uv);
            // sampledNormal = TransformTangentToWorld(sampledNormal, half3x3(IN.tangent.xyz, IN.bitangent, IN.normal)).xyz;
            // return half4(sampledNormal, 1.0);   

            float3 sampledNormal = UnpackNormalScale(SAMPLE_TEXTURECUBE(_BrushCube, sampler_BrushCube, IN.normal), 1.0).xyz;
            float3x3 ltw = localToWorld(IN.normal);
            sampledNormal = mul(ltw, sampledNormal);

            float fbm = fbm3D(IN.positionWS * _BrushFrequency);
            fbm = fbm * fbm * 2.0 - 1.0;
            // linear light blend
            normal += fbm * _FactorFbm;
            normal = lerp(normal, sampledNormal, _FactorBrush);
            // return half4(LinearLight(1, 0, _FactorBrush), 1.0);
            // normal = normalize(lerp(normal, sampledNormal, 0.5));
            float2 voronoi = voronoi3D(normal * 5.0 , normal);
            // return half4(normalize(normal), 1.0);
            Light light = GetMainLight(TransformWorldToShadowCoord(IN.positionWS));
            float lambert = saturate(dot(normalize(normal), light.direction) * 0.5 + 0.5);
            return _Color * lambert * light.shadowAttenuation * light.distanceAttenuation;
        }
        ENDHLSL

        Pass
        {
            Name "Paint"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }

        Pass
        { 
            Name "Paint ShadowCaster"
            Tags { "LightMode" = "ShadowCaster"}
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ShadowCasterFragment 
            half4 ShadowCasterFragment(Varyings input) : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }

    }
}