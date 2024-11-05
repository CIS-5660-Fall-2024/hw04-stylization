void GetMainLight_float(float3 WorldPos, out float3 Color, out float3 Direction, out float DistanceAtten, out float ShadowAtten)
{
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

void ComputeAdditionalLighting_float(float3 WorldPosition, float3 WorldNormal,
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
        
        if (thisDiffuse < Thresholds.x)
        {
            rampedDiffuse = RampedDiffuseValues.x;
        }
        else if (thisDiffuse < Thresholds.y)
        {
            rampedDiffuse = RampedDiffuseValues.y;
        }
        else
        {
            rampedDiffuse = RampedDiffuseValues.z;
        }
        
        
        if (shadowAtten * NdotL == 0)
        {
            rampedDiffuse = 0;

        }
        
        if (light.distanceAttenuation <= 0)
        {
            rampedDiffuse = 0.0;
        }

        Color += max(rampedDiffuse, 0) * light.color.rgb;
        Diffuse += rampedDiffuse;
    }
#endif
}

void ChooseColor_float(float3 Highlight, float3 Midtone, float3 Shadow, float Diffuse, float2 Thresholds, out float3 OUT)
{
    if (Diffuse < Thresholds.x)
    {
        OUT = Shadow;
    }
    else if (Diffuse < Thresholds.y)
    {
        OUT = Midtone;
    }
    else
    {
        OUT = Highlight;
    }
}

void getDynamicColor_float(
    float phase, float lerpFact,
    float3 h1, float3 m1, float3 s1,
    float3 h2, float3 m2, float3 s2,
    float3 h3, float3 m3, float3 s3,
    float3 h4, float3 m4, float3 s4,
    out float3 LerpHighlight, out float3 LerpMidtone, out float3 LerpShadow)
{
    LerpHighlight = h1;
    LerpMidtone = m1;
    LerpShadow = s1;
#ifndef SHADERGRAPH_PREVIEW
    if (phase < 1.0)
    {
        // Phase 0: Interpolate between Color Set 1 and Color Set 2
        LerpHighlight = lerp(h1, h2, lerpFact);
        LerpMidtone = lerp(m1, m2, lerpFact);
        LerpShadow = lerp(s1, s2, lerpFact);
    }
    else if (phase < 2.0)
    {
        // Phase 1: Interpolate between Color Set 2 and Color Set 3
        LerpHighlight = lerp(h2, h3, lerpFact);
        LerpMidtone = lerp(m2, m3, lerpFact);
        LerpShadow = lerp(s2, s3, lerpFact);
    }
    else if (phase < 3.0)
    {
        // Phase 2: Interpolate between Color Set 3 and Color Set 4
        LerpHighlight = lerp(h3, h4, lerpFact);
        LerpMidtone = lerp(m3, m4, lerpFact);
        LerpShadow = lerp(s3, s4, lerpFact);
    }
    else
    {
        // Phase 3: Interpolate between Color Set 4 and Color Set 1
        LerpHighlight = lerp(h4, h1, lerpFact);
        LerpMidtone = lerp(m4, m1, lerpFact);
        LerpShadow = lerp(s4, s1, lerpFact);
    }
#endif
}
