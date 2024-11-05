SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    //Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}


#if 0

static float2 dir[4] =
{
    float2(1, 0), float2(-1, 0), float2(0, 1), float2(0, -1)
};

void GetOutlineA_float(float rawDepth, float eyeDepth, float thickness, float2 uv, out float OUT)
{
    float d = rawDepth * eyeDepth;
    float sum = 0;
    for (int i = 0; i < 4; i++)
    {
        float2 curDir = dir[i] * thickness;
        float magic = GetEyeDepth(curDir);
        float magic2 = GetEyeDepth(uv);
        sum += magic - magic2;
    }
    
    OUT = max(sum, 0.0);
}

#endif
static float2 sobelSamplePoints[9] =
{
    float2(-1, 1), float2(0, 1), float2(1, 1),
    float2(-1, 0), float2(0, 0), float2(1, 0),
    float2(-1, -1), float2(0, -1), float2(1, -1)
};

static float sobelXMatrix[9] =
{
    -1, 0, 1,
    -2, 0, 2,
    -1, 0, 1
};

static float sobelYMatrix[9] =
{
    -1, -2, -1,
     0, 0, 0,
     1, 2, 1
};

void ApplySobel_float(float2 uv, float thick, out float sobelOut)
{
    float2 sobel = 0;
    
    [unroll] for (int i = 0; i < 9; i++)
    {
        float2 uvOffset = sobelSamplePoints[i] * thick * _ScreenParams.zw;
        float depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv + uvOffset);
        sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);
    }
    
    sobelOut = length(sobel);

}
