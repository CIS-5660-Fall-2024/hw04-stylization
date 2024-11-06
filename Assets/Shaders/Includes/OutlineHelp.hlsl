SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

void GetCrossSampleUVs_float(float2 UV, float2 TexelSize,
                             float OffsetMultiplier, out float2 UVOriginal,
                             out float2 UVTopRight, out float2 UVBottomLeft,
                             out float2 UVTopLeft, out float2 UVBottomRight) {
    UVOriginal = UV;
    UVTopRight = UV.xy + float2(TexelSize.x, TexelSize.y) * OffsetMultiplier;
    UVBottomLeft = UV.xy - float2(TexelSize.x, TexelSize.y) * OffsetMultiplier;
    UVTopLeft = UV.xy + float2(-TexelSize.x * OffsetMultiplier, TexelSize.y * OffsetMultiplier);
    UVBottomRight = UV.xy + float2(TexelSize.x * OffsetMultiplier, -TexelSize.y * OffsetMultiplier);
}
TEXTURE2D(_CameraColorTexture);
SAMPLER(sampler_CameraColorTexture);
void Outline_float(float2 UV, float OutlineThickness, float DepthSensitivity, float NormalsSensitivity, float ColorSensitivity, float Noise, out float Out)
{
    float halfScaleFloor = floor(OutlineThickness * 0.5) + Noise;
    float halfScaleCeil = ceil(OutlineThickness * 0.5) + Noise;
    float2 Texel = (1.0) / float2(1920.0,1080.0);

    float2 uvSamples[4];
    float depthSamples[4];
    float3 normalSamples[4], colorSamples[4];

    uvSamples[0] = UV - float2(Texel.x, Texel.y) * halfScaleFloor;
    uvSamples[1] = UV + float2(Texel.x, Texel.y) * halfScaleCeil;
    uvSamples[2] = UV + float2(Texel.x * halfScaleCeil, -Texel.y * halfScaleFloor);
    uvSamples[3] = UV + float2(-Texel.x * halfScaleFloor, Texel.y * halfScaleCeil);

    for (int i = 0; i < 4; i++)
    {
        depthSamples[i] = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uvSamples[i]);
        normalSamples[i] = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uvSamples[i]);
        colorSamples[i] = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, uvSamples[i]).rgb;
    }

    // Depth
    float depthFiniteDifference0 = depthSamples[1] - depthSamples[0];
    float depthFiniteDifference1 = depthSamples[3] - depthSamples[2];
    float edgeDepth = sqrt(pow(depthFiniteDifference0, 2) + pow(depthFiniteDifference1, 2)) * 100;
    float depthThreshold = (1 / DepthSensitivity) * depthSamples[0];
    edgeDepth = edgeDepth > depthThreshold ? 1 : 0;

    // Normals
    float3 normalFiniteDifference0 = normalSamples[1] - normalSamples[0];
    float3 normalFiniteDifference1 = normalSamples[3] - normalSamples[2];
    float edgeNormal = sqrt(dot(normalFiniteDifference0, normalFiniteDifference0) + dot(normalFiniteDifference1, normalFiniteDifference1));
    edgeNormal = edgeNormal > (1 / NormalsSensitivity) ? 1 : 0;

    // Color
    float3 colorFiniteDifference0 = colorSamples[1] - colorSamples[0];
    float3 colorFiniteDifference1 = colorSamples[3] - colorSamples[2];
    float edgeColor = sqrt(dot(colorFiniteDifference0, colorFiniteDifference0) + dot(colorFiniteDifference1, colorFiniteDifference1));
    edgeColor = edgeColor > (1 / ColorSensitivity) ? 1 : 0;

    Out = max(edgeDepth, max(edgeNormal, edgeColor));
}