void Grayscale_float(float3 colorIn, out float3 colorOut, out float luminance)
{
    float grayscale = dot(colorIn, float3(0.299, 0.587, 0.114));
    colorOut = float3(grayscale, grayscale, grayscale);
    luminance = grayscale;
}

void Sepia_float(float3 colorIn, float3 toneColor, out float3 colorOut) {
    float grayscale = dot(colorIn, float3(0.299, 0.587, 0.114));
    float3 sepiaColor = toneColor * grayscale;
    colorOut = sepiaColor;
}