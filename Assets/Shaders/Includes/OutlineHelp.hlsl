SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

void GetCrossSampleUVs_float(float4 UV, float2 TexelSize, 
        float OffsetMultiplier, out float2 UVOriginal, 
        out float2 UVTopRight, out float2 UVBottomLeft,
        out float2 UVTopLeft, out float2 UVBottomRight)
{
    UVOriginal = UV.xy;
    UVTopRight = UV.xy + TexelSize * OffsetMultiplier;
    UVBottomLeft = UV.xy - TexelSize * OffsetMultiplier;
    UVTopLeft = UV.xy + float2(-TexelSize.x, TexelSize.y) * OffsetMultiplier;
    UVBottomRight = UV.xy + float2(TexelSize.x, -TexelSize.y) * OffsetMultiplier;
}

static const float kernel[121] = { 0.006849, 0.007239, 0.007559, 0.007795, 0.007941, 0.00799, 0.007941, 0.007795, 0.007559, 0.007239, 0.006849, 0.007239, 0.007653, 0.00799, 0.00824, 0.008394, 0.008446, 0.008394, 0.00824, 0.00799, 0.007653, 0.007239, 0.007559, 0.00799, 0.008342, 0.008604, 0.008764, 0.008819, 0.008764, 0.008604, 0.008342, 0.00799, 0.007559, 0.007795, 0.00824, 0.008604, 0.008873, 0.009039, 0.009095, 0.009039, 0.008873, 0.008604, 0.00824, 0.007795, 0.007941, 0.008394, 0.008764, 0.009039, 0.009208, 0.009265, 0.009208, 0.009039, 0.008764, 0.008394, 0.007941, 0.00799, 0.008446, 0.008819, 0.009095, 0.009265, 0.009322, 0.009265, 0.009095, 0.008819, 0.008446, 0.00799, 0.007941, 0.008394, 0.008764, 0.009039, 0.009208, 0.009265, 0.009208, 0.009039, 0.008764, 0.008394, 0.007941, 0.007795, 0.00824, 0.008604, 0.008873, 0.009039, 0.009095, 0.009039, 0.008873, 0.008604, 0.00824, 0.007795, 0.007559, 0.00799, 0.008342, 0.008604, 0.008764, 0.008819, 0.008764, 0.008604, 0.008342, 0.00799, 0.007559, 0.007239, 0.007653, 0.00799, 0.00824, 0.008394, 0.008446, 0.008394, 0.00824, 0.00799, 0.007653, 0.007239, 0.006849, 0.007239, 0.007559, 0.007795, 0.007941, 0.00799, 0.007941, 0.007795, 0.007559, 0.007239, 0.006849 };

void weightedSum_float(float4 UV, float Threshold, float2 TexelSize, out float3 Color) {
    float weight;
    float3 texCol;
    for (int i = -5; i <= 5; i++)
    {
        for (int j = -5; j <= 5; j++)
        {
            weight = kernel[(i + 5) * 11 + (j + 5)];
            float2 uv = UV.xy + float2(float(i) * TexelSize.x, float(j) * TexelSize.y);
            texCol = SHADERGRAPH_SAMPLE_SCENE_COLOR(uv);
            //0.2126 * R + 0.7152 * G + 0.0722 * B
            if (0.2126 * texCol.r + 0.7152 * texCol.g + 0.0722 * texCol.b > Threshold) {
                Color += texCol * weight;
            }
        }
    }
}


