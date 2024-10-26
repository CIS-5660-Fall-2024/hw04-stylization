#pragma once
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
float4 _BaseMap_ST;

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

struct GeometryOut
{
    float4 positionCS : SV_POSITION;
    float2 texcoord : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normal : TEXCOORD2;
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


