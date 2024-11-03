void CosinePalette_float(float t, float3 a, float3 b, float3 c, float3 d, out float3 Color)
{
    Color = a + b * cos(TWO_PI * (c * t + d));
}