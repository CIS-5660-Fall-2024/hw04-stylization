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
 
void Choose3Color_float(float3 Highlight, float3 MidColor, float3 Shadow, float Diffuse, float2 Threshold, out float3 OUT)
{
    if (Diffuse < Threshold.x)
    {
        OUT = Shadow;
    }
    else if (Diffuse < Threshold.y)
    {
        OUT = MidColor;
    } 
    else 
    {
        OUT = Highlight;
    }
}

void Choose4Color_float(float3 Highlight, float3 MidColor, float3 Shadow, float3 SpecularColor, float Diffuse, float SpecularThreshold, float Specular, float2 Threshold, out float3 OUT)
{
    if (Diffuse < Threshold.x)
    {
        OUT = Shadow;
    }
    else if (Diffuse < Threshold.y)
    {
        OUT = MidColor;
    } 
    else 
    {
        OUT = Highlight;
    }
    if (Specular > SpecularThreshold) {
        OUT += SpecularColor;
    }
}

void ComputeAdditionalLighting_float(float3 WorldPosition, float3 WorldNormal, float noise,
    float2 Thresholds, float3 RampedDiffuseValues,
    out float3 Color, out float Diffuse)
{
    Color = float3(0, 0, 0);
    Diffuse = 0;

#ifndef SHADERGRAPH_PREVIEW

    int pixelLightCount = GetAdditionalLightsCount();
    
    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPosition);
        float4 tmp = unity_LightIndices[i / 4];
        uint light_i = tmp[i % 4];

        half shadowAtten = light.shadowAttenuation * AdditionalLightRealtimeShadow(light_i, WorldPosition, light.direction);
        
        half NdotL = saturate(dot(WorldNormal, light.direction)); 
        half distanceAtten = light.distanceAttenuation;

        half thisDiffuse = distanceAtten * shadowAtten * NdotL;
        
        half rampedDiffuse = 0;
        
        if (thisDiffuse < Thresholds.x + noise)
        {
            rampedDiffuse = RampedDiffuseValues.x;
        }
        else if (thisDiffuse < Thresholds.y + noise)
        {
            rampedDiffuse = RampedDiffuseValues.y;
        }
        else
        {
            rampedDiffuse = RampedDiffuseValues.z;
        }
        
        
        if (shadowAtten * NdotL <= noise)
        {
            rampedDiffuse = 0;

        }
        
        if (light.distanceAttenuation <= 0)
        {
            rampedDiffuse = 0.0;
        }

        Color += max(rampedDiffuse, 0) * light.color.rgb;
        Diffuse += thisDiffuse;
    }
#endif
}

void ComputeSpecular_float(float3 WorldPosition, float3 WorldNormal, float3 ViewDir, float specularHardness, out float Specular, out float3 SpecularColor) {
    Specular = 0;
    SpecularColor = float3(0, 0, 0);
#ifndef SHADERGRAPH_PREVIEW
    int pixelLightCount = GetAdditionalLightsCount();
    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPosition);
        float3 lightDir = light.direction;
		float distance = 1 / (light.distanceAttenuation * light.distanceAttenuation);

        float3 L = light.direction;
        float3 V = ViewDir;
        float3 H = (L + V) / length(L + V);
        float3 N = normalize(WorldNormal);
        float NdotH = dot(N, H);
        Specular += pow(saturate(NdotH), specularHardness) / distance;
        SpecularColor += light.color;
    }

// #if SHADOWS_SCREEN
//     float4 clipPos = TransformWorldToClip(WorldPosition);
//     float4 shadowCoord = ComputeScreenPos(clipPos);
// #else
//     float4 shadowCoord = TransformWorldToShadowCoord(WorldPosition);
// #endif
//     Light mainLight = GetMainLight(shadowCoord);
//     float3 lightDir = mainLight.direction;
// 	float distance = mainLight.distanceAttenuation * light.distanceAttenuation;
    
//     float3 L = mainLight.direction;
//     float3 V = ViewDir;
//     float3 H = (L + V) / length(L + V);
//     float3 N = normalize(WorldNormal);
//     float NdotH = dot(N, H);

//     Specular += pow(saturate(NdotH), specularHardness) / distance;
//     SpecularColor += mainLight.color;
#endif
}