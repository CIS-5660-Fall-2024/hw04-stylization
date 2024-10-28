// This Unity shader reconstructs the world space positions for pixels using a depth
// texture and screen space UV coordinates. The shader draws a checkerboard pattern
// on a mesh to visualize the positions.
Shader "Custom/Paint"
{
    Properties
    { 
        
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
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Assets/Shaders/Common.hlsl"
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
                float2 uv : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionHCS = vertexInput.positionCS;
                OUT.positionWS = TransformWorldToHClip(IN.positionOS);
                OUT.uv = IN.uv;
                
                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normal, IN.tangent);
                OUT.normal = normalInput.normalWS;
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 normal = IN.normal;
                float2 voronoi = voronoi3D(IN.normal * 5.0 , normal);
                return half4(normalize(normal) , 1.0);
                return 0;
            }
            ENDHLSL
        }
    }
}