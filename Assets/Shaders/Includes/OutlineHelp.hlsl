SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    //Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

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



static float2 fract(float2 uv)
{
    float x = uv.x - floor(uv.x);
    float y = uv.y - floor(uv.y);
    return float2(x, y);
}

static float2 random2(float2 p)
{
    return fract(sin(float2(dot(p, float2(127.1, 311.7)),
                 dot(p, float2(269.5, 183.3))))
                 * 43758.5453);
}

void WorleyNoise_float(float2 uv, float scale, out float2 outUV)
{
    //float scale = 100.0;
    uv *= scale; // Scale up the space to create smaller cells
    float2 uvInt = floor(uv);
    float2 uvFract = fract(uv);
    
    float minDist = 1.0; // Initialize minimum distance
    float2 closestCenter = float2(0.0, 0.0); // Initialize closest center

    // Loop through neighboring cells to find the closest center
    for (int y = -1; y <= 1; ++y)
    {
        for (int x = -1; x <= 1; ++x)
        {
            float2 neighbor = float2(float(x), float(y));
            float2 vorPoint = random2(uvInt + neighbor); // Get the center point in the neighboring cell
            float2 vorCenterUV = (uvInt + neighbor + vorPoint) / scale; // Convert back to UV space
            
            float2 diff = neighbor + vorPoint - uvFract;
            float dist = length(diff);
            
            if (dist < minDist)
            {
                minDist = dist;
                closestCenter = vorCenterUV;
            }
        }
    }

    outUV = closestCenter; // Output the UV coordinates of the center of the closest cell
}


