#define PI 3.1415926538

float3 GerstnerWave (float4 wave, float3 p, float time, inout float3 tangent, inout float3 binormal) {
    float steepness = wave.z;
    float wavelength = wave.w;
    float k = 2 * PI / wavelength;
    float c = sqrt(9.8 / k);
    float2 d = normalize(wave.xy);
    float f = k * (dot(d, p.xz) - c * time);
    float a = steepness / k;
    
    tangent += float3(1 - d.x * d.x * (steepness * cos(f)), -d.x * (steepness * sin(f)), -d.x * d.y * (steepness * cos(f)));

    binormal += float3(-d.x * d.y * (steepness * cos(f)), -d.y * (steepness * sin(f)), 1 - d.y * d.y * (steepness * cos(f)));

    return float3(d.x * (a * cos(f)), a * sin(f), d.y * (a * cos(f)));
}

void Gerstner_float(float3 posIn, float time, out float3 posOut, out float3 normalOut)
{
    // direction (xy), steepness(z), wavelength(w)
    float4 wave1 = float4(1,1,0.5,1);
    float4 wave2 = float4(0,1,0.25,2);
    float4 wave3 = float4(1,0,0.25,1);

    float3 gridPoint = posIn;
    float3 tangent = float3(0,0,0);
    float3 binormal = float3(0,0,0);
    float3 p = gridPoint;
    p += GerstnerWave(wave1, gridPoint, time, tangent, binormal);
    p += GerstnerWave(wave2, gridPoint, time, tangent, binormal);
    p += GerstnerWave(wave3, gridPoint, time, tangent, binormal);

    float3 normal = normalize(cross(binormal, tangent));
    posOut = p;
    normalOut = normal;
}
