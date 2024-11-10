void NoiseBlendOnEdges_float(
    float2 position, float borderWidth, out float BLENDALPHA
)
{
    if (position.x > 1.0 - borderWidth && position.y > 1.0 - borderWidth)
    {
        float alphax = 1.0 - ((position.x - (1.0 - borderWidth)) / borderWidth);
        float alphay = 1.0 - ((position.y - (1.0 - borderWidth)) / borderWidth);
        BLENDALPHA = (alphax * alphay);
    }
    else if (position.x > 1.0 - borderWidth)
    {
        BLENDALPHA = 1.0 - ((position.x - (1.0 - borderWidth)) / borderWidth);
    }
    else if (position.y > 1.0 - borderWidth)
    {
        BLENDALPHA = 1.0 - ((position.y - (1.0 - borderWidth)) / borderWidth);
    }
}

void MoveNoiseOnCycle_float(
    float time, out float2 translate
)
{
    if (time % 3 > 2)
    {
        translate = float2(-5.f, -5.f);
    }
    else if (time % 3 > 1)
    {
        translate = float2(0.f, 10.f);
    }
    else
    {
        translate = float2(5.f, 5.f);
    }
}