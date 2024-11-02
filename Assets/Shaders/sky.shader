// This Unity shader reconstructs the world space positions for pixels using a depth
// texture and screen space UV coordinates. The shader draws a checkerboard pattern
// on a mesh to visualize the positions.
Shader "Custom/StyleizeSky"
{
    Properties
    { 
        [Header(Brush)][Space]
        _BrushNormalScale ("Brush Normal Scale", Range(0.5, 3.0)) = 1.5
        _BrushCube1 ("Brush Cube1", CUBE) = "white" {}
        _BrushCube2 ("Brush Cube2", CUBE) = "white" {}

        [Toggle(_UseRamp)] _URamp ("Use Ramp", Float) = 1
        _ColorRamp ("Color Ramp", 2D) = "white" {}
        _VoronoiSize ("Voronoi Size", Range(1.0, 7.0)) = 5.0
        _Color ("Color", Color) = (1,1,1,1)
        _ColorTransition ("Color Transition", Range(0.01, 1)) = 0.5
        _FbmBrushFrequency ("Brush Frequency", Range(0.1, 10)) = 0.5
        _FbmBrushStrength ("Brush Strength", Range(0.1, 10)) = 1.0  
        _FactorFbm ("Factor Fbm", Range(0.01, 1)) = 0.5
        _FactorBrush ("Factor Brush", Range(0.01, 1)) = 0.5

        [Header(Rim)][Space]
        _RimThreshold ("Rim Threshold", Range(0.001, 0.03)) = 0.1
        _RimKernel ("Rim Kernel", Range(0.001, 0.1)) = 0.01
        _RimScale ("Rim Scale", Range(0.5, 3.0)) = 1.5
        [Toggle(_UseHalfLambert)] _UHLambert ("Use Half Lambert", Float) = 1

        [Header(Sun)][Space]
        _FlareTex ("Flare Texture", 2D) = "white" {}
        _SunColor ("Sun Color", Color) = (1,1,1,1)
        _SunIntensity ("Sun Intensity", Range(0.1, 10)) = 1.0
        _InnerSize ("Sun Size", Range(0.97, 1)) = 0.1
        _Fade ("Fade", Range(0.001, 0.02)) = 0.01
    }

    // The SubShader block containing the Shader code.
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        // Blend SrcAlpha OneMinusSrcAlpha
        // Cull Front
        // ZWrite Off
        // ZTest Off
        UsePass "Universal Render Pipeline/Lit/DepthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
        
        ZWrite On

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Assets/Shaders/Common.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        
        

        CBUFFER_START(UnityPerMaterial)
        float _BrushNormalScale;
        float4 _Color;
        float _VoronoiSize;
        float _FbmBrushFrequency;
        float _FbmBrushStrength;
        float _FactorFbm;
        float _FactorBrush;
        float _RimThreshold;
        float _RimKernel;
        float _RimScale;
        float _ColorTransition;
        float4 _SunColor;
        float _SunIntensity;
        float _InnerSize;
        float _Fade;
        CBUFFER_END


        TEXTURECUBE(_BrushCube1);
        SAMPLER(sampler_BrushCube1);
        TEXTURECUBE(_BrushCube2);
        SAMPLER(sampler_BrushCube2);
        TEXTURE2D(_ColorRamp);
        SAMPLER(sampler_ColorRamp);
        TEXTURE2D(_FlareTex);
        SAMPLER(sampler_FlareTex);

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

        float getDepth(float2 uv)
        {
            // Sample the depth from the Camera depth texture.
        #if UNITY_REVERSED_Z
            real depth = SampleSceneDepth(uv);
        #else
            // Adjust Z to match NDC for OpenGL ([-1, 1])
            real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(uv));
        #endif
            return Linear01Depth(depth, _ZBufferParams);
        }
        #define POW5(x) ((x) * (x) * (x) * (x) * (x))
        half4 frag(Varyings IN) : SV_Target
        {
            // screen uv
            float2 UV = IN.positionHCS.xy / _ScaledScreenParams.xy;
            float3x3 ltO = localToWorld(IN.positionOS);
            float3 normal = normalize(IN.positionWS);
            float3 V = normalize(_WorldSpaceCameraPos - IN.positionWS);
            


            // overlay blend brush normal
            float3 brushNormal1 = UnpackNormalScale(SAMPLE_TEXTURECUBE(_BrushCube1, sampler_BrushCube1, normalize(IN.positionOS)), _BrushNormalScale).xyz;
            brushNormal1 = mul(ltO, brushNormal1);
            // float3 brushNormal2 = UnpackNormalScale(SAMPLE_TEXTURECUBE(_BrushCube2, sampler_BrushCube2, normalize(IN.positionOS)), _BrushNormalScale).xyz;
            float3 brushNormal2 = float3(0, 0, 1);
            brushNormal2 = mul(ltO, brushNormal2);
            float3 brushNormal = overlay(brushNormal1 * 0.5 + 0.5, brushNormal2 * 0.5 + 0.5);

            float2 fbm = float2((fbm3D(normalize(IN.positionOS)* _FbmBrushFrequency) - 0.5) * _FbmBrushStrength ,(fbm3D(normalize(IN.positionOS) * _FbmBrushFrequency) - 0.5) * _FbmBrushStrength);
            fbm = fbm * fbm * fbm;
            float3 fbmNormal = mul(ltO, normalize(float3(fbm, 1.0)));

            // linear light blend normal
            normal = lerp(normal, fbmNormal, _FactorFbm);
            normal = lerp(normal, brushNormal * 2.0 - 1.0, _FactorBrush);

            // voronoi using distorted normal as input
            float3 voronoiNormal;
            float2 voronoi = voronoi3D(normal * _VoronoiSize , voronoiNormal);
            normal = normalize(voronoiNormal * 2.0 - 1.0);
            
            // depth based rim mask
            float fragDepth = getDepth(UV);
            float3 normalView = normalize(mul((UNITY_MATRIX_V), normal).xyz);

            float depth = getDepth(UV + normalView.xy * _RimKernel * (0.9 - 0.9 * fragDepth));
            float depthDiff = abs(fragDepth - depth);
            float rim = saturate(depthDiff / max(0.0001, _RimThreshold));
            rim = smoothstep(0.03, 1.0, rim) * _RimScale;
            // light contributions
            float3 lightContribution = 0;

            // main light
            Light light = GetMainLight();
            float lambert = dot(normalize(normal), float3(0, 1, 0));
        #ifdef _UseHalfLambert
            float hlambert = lambert * 0.5 + 0.5;
        #else
            float hlambert = saturate(lambert);
        #endif
            
        #ifdef _UseRamp
            float3 color = SAMPLE_TEXTURE2D(_ColorRamp, sampler_ColorRamp, float2(hlambert, 0.5)).xyz;
        #else
            float3 color = _Color.rgb * (getGain(hlambert, _ColorTransition) * 0.8 + 0.2);
        #endif
            float3 lighting = light.color;

            lightContribution += lighting * (color);

            
            // draw sun
            float sunAngle = dot(normalize(IN.positionWS), light.direction);
            UV = IN.positionHCS.xy / _ScaledScreenParams.y;
            float flareMask = SAMPLE_TEXTURE2D(_FlareTex, sampler_FlareTex, float2(1.0 - sunAngle, 0.5)).r;
            if (sunAngle > _InnerSize)
            {
                return half4(_SunColor.rgb * _SunIntensity * 10.0, 1.0);
            } else if (sunAngle > _InnerSize - _Fade)
            {
                float t = 1.0 - saturate((sunAngle - (_InnerSize - _Fade)) / _Fade);
                t = smoothstep(0.2, 0.8, t);
                return half4(lerp(_SunColor.rgb * _SunIntensity * 10.0, lightContribution, t), 1.0);
            }

            return half4(lightContribution, 1.0);
        }
        ENDHLSL

        Pass
        {
            Name "Paint"
            Tags { "RenderType" = "Background" "RenderPipeline" = "UniversalPipeline" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _UseRamp
            #pragma shader_feature _UseHalfLambert
            ENDHLSL
        }

    }
}