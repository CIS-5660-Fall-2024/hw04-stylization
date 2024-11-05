SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

void GetCrossSampleUVs_float(
    float4 uv, 
    float2 texelSize,
    float offsetMultiplier, 
    out float2 uvOriginal, 
    out float2 uvTopRight, 
    out float2 uvBottomLeft, 
    out float2 uvTopLeft, 
    out float2 uvBottomRight
) {
    uvOriginal = uv; 
    uvTopRight = uv.xy + float2(texelSize.x, texelSize.y) * offsetMultiplier; 
    uvBottomLeft = uv.xy - float2(texelSize.x, texelSize.y) * offsetMultiplier;
    uvTopLeft = uv.xy + float2(-texelSize.x * offsetMultiplier, texelSize.y * offsetMultiplier); 
    uvBottomRight = uv.xy + float2(texelSize.x * offsetMultiplier, -texelSize.y * offsetMultiplier); 
}