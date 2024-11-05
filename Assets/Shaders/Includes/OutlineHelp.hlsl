SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

static float2 sobelSamplePoints[9] = {
    float2(-1, 1),float2(0, 1),float2(1, 1),
	float2(-1, 0),float2(0, 0),float2(1, 1),
	float2(-1, -1),float2(0, -1),float2(1, -1)
};

static float sobelXMatrix[9] = {
	-1, 0, 1,
	-2, 0, 2,
	-1, 0, 1,
};

static float sobelYMatrix[9] = {
	1, 2, 1,
	0, 0, 0,
	-1, -2, -1,
};

float SimpleNoise(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

void DepthSobel_float(float2 UV, float Thickness,float time,float distortion,out float Out) {
    float2 sobel = 0;
	[unroll] for (int i = 0; i < 9; i++) {
		float depth = 0;
		// 0 - 1
		float noiseValue = SimpleNoise(UV + sobelSamplePoints[i]);
        float2 noiseOffset = float2(sin(time + noiseValue), cos(time + noiseValue)) * 1.4;

		GetDepth_float(UV + sobelSamplePoints[i] * Thickness + time * distortion * noiseOffset, depth);
		sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);
	}
	Out = length(sobel);
}

void ACESFilm_float(float3 InColor, out float3 OutColor) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    OutColor = saturate((InColor* (a * InColor + b)) / (InColor * (c * InColor + d) + e));
}