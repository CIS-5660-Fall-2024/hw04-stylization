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

        
        if (light.distanceAttenuation <= 0)
        {
            rampedDiffuse = 0.0;
        }

        Color += max(rampedDiffuse, 0) * light.color.rgb;
        Diffuse += rampedDiffuse;
    }
    
    if (Diffuse <= 0.3)
    {
        Color = float3(0, 0, 0);
        Diffuse = 0;
    }
    
#endif
}

void ChooseColor_float(float3 Highlight, float3 Midtone, float3 Shadow,
    float Diffuse, float2 Thresholds, float Noise, float StippleBandThickness,
    out float3 OUT)
{
    if (Diffuse < Thresholds.x)
    {
        float lerpAlpha = (Diffuse - (Thresholds.x - StippleBandThickness)) / StippleBandThickness;
        
        if (Diffuse > Thresholds.x - StippleBandThickness && Noise < lerp(0.f, 1.f, lerpAlpha))
        {
            OUT = Midtone;
        }
        else
        {
            OUT = Shadow;
        }
    }
    else if (Diffuse < Thresholds.y)
    {
        float lerpAlpha = (Diffuse - (Thresholds.y - StippleBandThickness)) / StippleBandThickness;
        
        if (Diffuse > Thresholds.y - StippleBandThickness && Noise < lerp(0.f, 1.f, lerpAlpha))
        {
            OUT = Highlight;
        }
        else
        {
            OUT = Midtone;
        }
   
    }
    else
    {
        //float lerpAlpha = ((Thresholds.y + 0.1f) - Diffuse) / 0.1f;
        
        //if (Diffuse < Thresholds.y + 0.1f && noise > lerp(1.f, 0.f, lerpAlpha))
        //{
        //    OUT = Midtone;
        //}
        //else
        //{
        //    OUT = Highlight;
        //}
        OUT = Highlight;
    }
}
