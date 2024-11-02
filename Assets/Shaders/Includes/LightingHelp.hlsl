void GetMainLight_float(float3 WorldPos, out float3 Color, out float3 Direction, out float DistanceAtten, out float ShadowAtten) {
#ifdef SHADERGRAPH_PREVIEW
    Direction = normalize(float3(0.5, 0.5, 0));
    Color = 1;
    DistanceAtten = 1;
    ShadowAtten = 1;
#else
    #if SHADOWS_SCREEN
        float4 clipPos = TransformWorldToClip(WorldPos);
        float4 shadowCoord = ComputeScreenPos(clipPos);
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
    #endif

    Light mainLight = GetMainLight(shadowCoord);
    Direction = mainLight.direction;
    Color = mainLight.color;
    DistanceAtten = mainLight.distanceAttenuation;
    ShadowAtten = mainLight.shadowAttenuation;
#endif
}

void ComputeAdditionalLight_float(float3 WorldPos, float3 WorldNor, out float Diffuse, out float3 Color)
{
	Diffuse = 0;
	Color = float3(0, 0, 0);
#ifndef SHADERGRAPH_PREVIEW
	int lightCnt = GetAdditionalLightsCount();

	for (int i = 0; i < lightCnt; i++)
	{
		Light light = GetAdditionalLight(i, WorldPos);
		float4 tmp = unity_LightIndices[i / 4];
		uint light_i = tmp[i % 4];

		float shadowAtten = light.shadowAttenuation * AdditionalLightRealtimeShadow(light_i, WorldPos, light.direction);
		float distanceAtten = light.distanceAttenuation;
		float NdotL = saturate(dot(WorldNor, light.direction));

		float diffuse = NdotL * distanceAtten * shadowAtten;
		Color += light.color * diffuse;
		Diffuse += diffuse;
	}
#endif
}

void ComputeSurfaceColor_float(float3 baseCol, float3 directCol, float diffuse1, float3 indirectCol, float diffuse2, out float3 OUT)
{
	float weightSum = diffuse1 + diffuse2;
	if (weightSum < 0.05f)
	{
		OUT = baseCol;
		return;
	}
	OUT = baseCol * (directCol * diffuse1 + indirectCol) / weightSum;
}

void ChooseColor_float(float3 Highlight, float3 Shadow, float Diffuse, float Threshold, out float3 OUT)
{
    if (Diffuse < Threshold)
    {
        OUT = Shadow;
    }
    else
    {
        OUT = Highlight;
    }
}

void IntensityCurve_float(float Diffuse, float Threshold1, float Threshold2, float Shadow, float Midtone, float Hightlight, out float OUT)
{
	if (Diffuse < Threshold1)
	{
		OUT = Shadow;
	}
	else if (Diffuse < Threshold2)
	{
        OUT = Midtone;
	}
	else
	{
		OUT = Hightlight;
	}
}