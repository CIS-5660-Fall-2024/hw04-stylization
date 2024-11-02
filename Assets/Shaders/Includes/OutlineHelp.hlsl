SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalBuffer, sampler_point_clamp, uv).rgb;
    //Normal = SAMPLE_TEXTURE2D(_NormalBuffer, sampler_point_clamp, uv).rgb * 2.0f - float3(1.0f, 1.0f, 1.0f);
}

float3 DecodeNormal(float3 enc)
{
    float kScale = 1.7777;
    float3 nn = enc.xyz*float3(2*kScale,2*kScale,0) + float3(-kScale,-kScale,1);
    float g = 2.0 / dot(nn.xyz,nn.xyz);
    float3 n;
    n.xy = g*nn.xy;
    n.z = g-1;
    return n;
}

void Scanline_float(float2 uv, float freq, float time, out float OUT)
{
    float y = uv.y * freq;
    float illuY = sin(y + time) + 0.7f;
    OUT = illuY;
}

void DrawOutline_float(float2 UV, float OutlineThickness, float DepthSensitivity, float NormalsSensitivity, out float OUT)
{
    
    float halfScaleFloor = floor(OutlineThickness * 0.5f);
    float halfScaleCeil = ceil(OutlineThickness * 0.5f);
    float2 Texel = (1.0f) / float2(2560.0f, 1440.0f);

    //ds
    float2 uvSamples[4];
    uvSamples[0] = UV - float2(Texel.x, Texel.y) * halfScaleFloor;
    uvSamples[1] = UV + float2(Texel.x, Texel.y) * halfScaleCeil;
    uvSamples[2] = UV + float2(Texel.x * halfScaleCeil, -Texel.y * halfScaleFloor);
    uvSamples[3] = UV + float2(-Texel.x * halfScaleFloor, Texel.y * halfScaleCeil);

    float depthSamples[4];
    float3 normalSamples[4];//, colorSamples[4];

    for(int i = 0; i < 4 ; i++)
    {
        depthSamples[i] = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uvSamples[i]);
        normalSamples[i] = DecodeNormal(SAMPLE_TEXTURE2D(_NormalBuffer, sampler_point_clamp, uvSamples[i]));
        //colorSamples[i] = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, uvSamples[i]);
    }

    float depthFiniteDifference0 = depthSamples[1] - depthSamples[0];
    float depthFiniteDifference1 = depthSamples[3] - depthSamples[2];
    float edgeDepth = sqrt(pow(depthFiniteDifference0, 2) + pow(depthFiniteDifference1, 2)) * 100.0f;
    float depthThreshold = (1.0f / DepthSensitivity) * depthSamples[0];
    edgeDepth = edgeDepth > depthThreshold ? 1 : 0;

    float3 normalFiniteDifference0 = normalSamples[1] - normalSamples[0];
    float3 normalFiniteDifference1 = normalSamples[3] - normalSamples[2];
    float edgeNormal = sqrt(dot(normalFiniteDifference0, normalFiniteDifference0) + dot(normalFiniteDifference1, normalFiniteDifference1));
    edgeNormal = edgeNormal > (1.0f /NormalsSensitivity) ? 1 : 0;

    OUT = max(edgeDepth, edgeNormal);
    //OUT = DecodeNormal(SAMPLE_TEXTURE2D(_NormalBuffer, sampler_point_clamp, UV).rgb);
}