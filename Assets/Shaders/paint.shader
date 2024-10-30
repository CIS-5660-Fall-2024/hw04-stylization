// This Unity shader reconstructs the world space positions for pixels using a depth
// texture and screen space UV coordinates. The shader draws a checkerboard pattern
// on a mesh to visualize the positions.
Shader "Custom/Paint"
{
    Properties
    { 
        _BrushCube1 ("Brush Cube1", CUBE) = "white" {}
        _BrushCube2 ("Brush Cube2", CUBE) = "white" {}
        _ColorRamp ("Color Ramp", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _BrushFrequency ("Brush Frequency", Range(0.1, 10)) = 0.5
        _FactorFbm ("Factor Fbm", Range(0.01, 1)) = 0.5
        _FactorBrush ("Factor Brush", Range(0.01, 1)) = 0.5
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


        TEXTURECUBE(_BrushCube1);
        SAMPLER(sampler_BrushCube1);
        TEXTURECUBE(_BrushCube2);
        SAMPLER(sampler_BrushCube2);
        TEXTURE2D(_ColorRamp);
        SAMPLER(sampler_ColorRamp);

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
            // screen uv
            float2 UV = IN.positionHCS.xy / _ScaledScreenParams.xy;
            float3x3 ltw = localToWorld(IN.normal);
            float3 normal = IN.normal;
            // float3 brushNormal = SAMPLE_TEXTURE2D(_BrushMap, sampler_BrushMap, IN.uv);
            // brushNormal = TransformTangentToWorld(brushNormal, half3x3(IN.tangent.xyz, IN.bitangent, IN.normal)).xyz;
            // return half4(brushNormal, 1.0);   

            float3 brushNormal1 = UnpackNormalScale(SAMPLE_TEXTURECUBE(_BrushCube1, sampler_BrushCube1, normalize(IN.positionOS)), 1.0).xyz;
            brushNormal1 = mul(ltw, brushNormal1);
            float3 brushNormal2 = UnpackNormalScale(SAMPLE_TEXTURECUBE(_BrushCube2, sampler_BrushCube2, normalize(IN.positionOS)), 1.0).xyz;
            brushNormal2 = mul(ltw, brushNormal2);
            float3 brushNormal = overlay(brushNormal1 * 0.5 + 0.5, brushNormal2 * 0.5 + 0.5);

            float2 fbm = float2(fbm3D(IN.positionOS * 41.1226 * _BrushFrequency), fbm3D(IN.positionOS * 38.7116 * _BrushFrequency));
            fbm = fbm * fbm * 2.0 - 1.0;
            float3 fbmNormal = mul(ltw, normalize(float3(fbm, 1.0)));

            float3 voronoiNormal;
            float2 voronoi = voronoi3D(IN.normal * 5.0 , voronoiNormal);
            voronoiNormal = normalize(voronoiNormal);

            // return half4(voronoiNormal * 0.5 + 0.5, 1.0);
            // overlay blend
            normal = overlay((fbmNormal * 0.5 + 0.5) * _FactorFbm , voronoiNormal * 0.5 + 0.5);
            normal = overlay((brushNormal * 0.5 + 0.5) * _FactorBrush, normal);
            // return half4(normalize(normal * 2.0 - 1.0), 1.0);
            return half4(normalize(brushNormal * 2.0 - 1.0), 1.0);
            Light light = GetMainLight(TransformWorldToShadowCoord(IN.positionWS));
            float lambert = dot(normalize(normal), light.direction);
            float hlambert = lambert * 0.5 + 0.5;
            float4 color = SAMPLE_TEXTURE2D(_ColorRamp, sampler_ColorRamp, float2(hlambert, 0.5));
            return color * light.shadowAttenuation * light.distanceAttenuation;
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