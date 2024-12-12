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

//lecture notes
float noise1D(float2 uv) {
    return frac(sin(dot(uv, float2(127.1, 311.7))) *
                 43758.5453);
}

void DepthSobel_float(float2 UV, float Thickness, float Time, float Distortion, float NoiseIntensity, out float Out) {
    float2 sobel = 0;

    [unroll]
    for (int i = 0; i < 9; i++) {
        float depth = 0;

        float noiseValue = noise1D(UV + sobelSamplePoints[i]);

        float2 noiseOffset = float2(
            sin(Time + noiseValue),
            cos(Time + noiseValue)
        ) * NoiseIntensity;

        GetDepth_float(UV + sobelSamplePoints[i] * Thickness + Time * Distortion * noiseOffset, depth);

        sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);
    }
    Out = length(sobel);
}


/*
void DepthSobel_float(float2 UV, float Thickness, out float Out) {
    float2 sobel = 0;
	[unroll] for (int i = 0; i < 9; i++) {
		float depth = 0;
		
		GetDepth_float(UV + sobelSamplePoints[i] * Thickness, depth);
		sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);
	}
	Out = length(sobel);
}
*/

void ColorSobel_float(float2 UV, float Thickness, float Time, float Distortion, float NoiseIntensity, out float Out) {
    float2 sobelR = 0;
    float2 sobelG = 0;
    float2 sobelB = 0;

    [unroll]
    for (int i = 0; i < 9; i++) {
        float noiseValue = noise1D(UV + sobelSamplePoints[i]);

        float2 noiseOffset = float2(
            sin(Time + noiseValue),
            cos(Time + noiseValue)
        ) * NoiseIntensity;

        float3 rgb = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV + sobelSamplePoints[i] * Thickness + Time * Distortion * noiseOffset);

        float2 kernel = float2(sobelXMatrix[i], sobelYMatrix[i]);
        sobelR += rgb.r * kernel;
        sobelG += rgb.g * kernel;
        sobelB += rgb.b * kernel;
    }
    Out = max(length(sobelR), max(length(sobelG), length(sobelB)));
}

/*
void ColorSobel_float(float2 UV, float Thickness, out float Out) {
    float2 sobelR = 0;
    float2 sobelG = 0;
    float2 sobelB = 0;

    [unroll] for (int i = 0; i < 9; i++) {
        float3 rgb = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV + sobelSamplePoints[i] * Thickness);

        float2 kernel = float2(sobelXMatrix[i], sobelYMatrix[i]);

        sobelR += rgb.r * kernel;
        sobelG += rgb.g * kernel;
        sobelB += rgb.b * kernel;
    }

    Out = max(length(sobelR), max(length(sobelG), length(sobelB)));
} */

void Vignette_float(float2 UV, float EdgeSoftness, float Intensity, out float Out)
{
    float2 center = float2(0.5, 0.5);
    float dist = length(UV - center);

    float vignette = 1.0 - smoothstep(1.0 - EdgeSoftness, 1.0, dist);

    Out = vignette * Intensity;
}
