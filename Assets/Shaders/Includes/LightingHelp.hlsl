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

// Permutation table to pseudo-randomize the input
int permute(int x) {
    return ((34 * x + 1) * x) % 289;
}

// Gradient function for Perlin noise
float grad(int hash, float x, float y, float z) {
    int h = hash & 15;
    float u = h < 8 ? x : y;
    float v = h < 4 ? y : h == 12 || h == 14 ? x : z;
    return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
}

// 3D Perlin Noise function
void perlin3D_float(float3 p, out float OUT) {
    float3 Pi = floor(p);          // Integer part
    float3 Pf = p - Pi;             // Fractional part
    Pi = fmod(Pi, 289.0);           // Modulo 289 to stay in range

    float3 Pf3 = Pf * Pf * Pf * (Pf * (Pf * 6.0 - 15.0) + 10.0); // Fade function

    // Hash coordinates of the 8 cube corners
    int A = permute(int(Pi.x)) + int(Pi.y);
    int AA = permute(A) + int(Pi.z);
    int AB = permute(A + 1) + int(Pi.z);
    int B = permute(int(Pi.x + 1)) + int(Pi.y);
    int BA = permute(B) + int(Pi.z);
    int BB = permute(B + 1) + int(Pi.z);

    // Add blended results from all corners
    float res = lerp(
        lerp(lerp(grad(permute(AA), Pf.x, Pf.y, Pf.z),
            grad(permute(BA), Pf.x - 1.0, Pf.y, Pf.z),
            Pf3.x),
            lerp(grad(permute(AB), Pf.x, Pf.y - 1.0, Pf.z),
                grad(permute(BB), Pf.x - 1.0, Pf.y - 1.0, Pf.z),
                Pf3.x),
            Pf3.y),
        lerp(lerp(grad(permute(AA + 1), Pf.x, Pf.y, Pf.z - 1.0),
            grad(permute(BA + 1), Pf.x - 1.0, Pf.y, Pf.z - 1.0),
            Pf3.x),
            lerp(grad(permute(AB + 1), Pf.x, Pf.y - 1.0, Pf.z - 1.0),
                grad(permute(BB + 1), Pf.x - 1.0, Pf.y - 1.0, Pf.z - 1.0),
                Pf3.x),
            Pf3.y),
        Pf3.z);
    OUT = res; 
}