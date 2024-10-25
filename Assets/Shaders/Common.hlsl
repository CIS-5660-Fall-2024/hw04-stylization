// NoiseCommon.hlsl
float hash13(float3 p)
{
    return frac(sin(dot(p ,float3(12.9898,78.233,126.7378))) * 43758.5453)*2.0-1.0;
}

float3 grad(float3 p)
{
    return float3(hash13(p*1.00), hash13(p*1.12), hash13(p*1.23));
}

float perlin3D(float3 q)
{
    float3 f = frac(q);
    float3 p = floor(q);
    f = f*f*(3.0-2.0*f);

    float p0	= dot(grad(p), q-p);
    float x 	= dot(grad(p+float3(1.0,0.0,0.0)), q-(p+float3(1.0,0.0,0.0)));
    float y 	= dot(grad(p+float3(0.0,1.0,0.0)), q-(p+float3(0.0,1.0,0.0)));
    float z 	= dot(grad(p+float3(0.0,0.0,1.0)), q-(p+float3(0.0,0.0,1.0)));
    float xy	= dot(grad(p+float3(1.0,1.0,0.0)), q-(p+float3(1.0,1.0,0.0)));
    float xz	= dot(grad(p+float3(1.0,0.0,1.0)), q-(p+float3(1.0,0.0,1.0)));
    float yz	= dot(grad(p+float3(0.0,1.0,1.0)), q-(p+float3(0.0,1.0,1.0)));
    float xyz	= dot(grad(p+1.0), q-(p+1.0));

    return lerp(	lerp(	lerp(p0, x, 	 f.x), 
                        lerp(y, 	xy,  f.x), 	f.y), 
                lerp(	lerp(z, 	xz,	 f.x), 
                        lerp(yz, xyz, f.x), 	f.y), 	f.z);
}

float perlin2D(float2 q)
{
    float2 f = frac(q);
    float2 p = floor(q);
    f = f*f*(3.0-2.0*f);

    float p0	= dot(grad(float3(p, 0.0)), float3(q, 0.0)-float3(p, 0.0));
    float x 	= dot(grad(float3(p+float2(1.0,0.0), 0.0)), float3(q, 0.0)-float3(p+float2(1.0,0.0), 0.0));
    float y 	= dot(grad(float3(p+float2(0.0,1.0), 0.0)), float3(q, 0.0)-float3(p+float2(0.0,1.0), 0.0));
    float xy	= dot(grad(float3(p+float2(1.0,1.0), 0.0)), float3(q, 0.0)-float3(p+float2(1.0,1.0), 0.0));

    return lerp(	lerp(p0, x, f.x), 
                lerp(y, xy, f.x), f.y);
}

float fbmPerlin(float2 p, float freq, float amp, int octaves)
{
    float v = 0.0;
    float a = 1.0;
    float f = freq;
    for(int i = 0; i < octaves; i++)
    {
        v += a * perlin2D(p * f);
        f *= 2.0;
        a *= amp;
    }
    return v;
}

// k represents output color
// p is the position in world space
// offset is used to make the caustics move 
void getCaustics(out float4 k, float3 p, float offset)
{
    k = 1;
    k.xyz = p*(2.)/2e2 +0.1 * offset;
    k.xyz += perlin3D(k.xyz +0.2 * offset);
    float3 v = mul(k.xyz, float3x3(-2,-1,2, 3,-2,1, 1,2,2));
    // float3 v = k.xyz;
    float layer1 = length(.5-frac((v + 114.514) * 0.5));
    float layer2 = length(.5-frac((v + 1919.810) * 0.4));
    float layer3 = length(.5-frac((v + 3378.45818) * 0.3));
    k = pow(min(min(layer1,layer2),layer3), 7.)*25.;
}

float zebra(float2 p, float thres)
{
    return step(thres, frac(p.x));
}

float sinWave(float3 p, float freq, float amp)
{
    return length((sin(p*freq)*amp));
}

float getBias(float time, float bias)
{
    return (time / ((((1.0 / bias) - 2.0) * (1.0 - time)) + 1.0));
}

float getGain(float time, float gain)
{
    if(time < 0.5)
        return getBias(time * 2.0, gain) / 2.0;
    else
        return getBias(time * 2.0 - 1.0, 1.0 - gain) / 2.0 + 0.5;
}

float3x3 localToWorld(float3 N)
{
    float3 up = abs(N.z) < 0.999 ? float3(0,0,1) : float3(1,0,0);
    float3 T = normalize(cross(up, N));
    float3 B = cross(N, T);
    return float3x3(T, B, N);
}