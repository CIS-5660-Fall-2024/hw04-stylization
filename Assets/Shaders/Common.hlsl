#define PI 3.14159265359
#define PI_HALF 1.57079632679
#define PI_TWO 6.28318530718
#define INV_PI 0.31830988618

// NoiseCommon.hlsl
float hash13(float3 p)
{
    return frac(sin(dot(p ,float3(12.9898,78.233,126.7378))) * 43758.5453);
}

float3 hash33(float3 p)
{
    return float3(hash13(p*1.00), hash13(p*1.12), hash13(p*1.23));
}

float3 grad(float3 p)
{

    return float3(hash13(p*1.00) * 2.0 - 1.0, hash13(p*1.12) * 2.0 - 1.0, hash13(p*1.23) * 2.0 - 1.0);
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

float2 voronoi3D(float3 pos, out float3 pivot) {
    float3 p = floor(pos);
    float3 f = frac(pos);
    float2 min_dist = 100.0;
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            for(int z = -1; z <= 1; z++) {
                float3 neighbor = float3(x, y, z);
                float3 pt = hash33(p + neighbor);
                float3 diff = neighbor + pt - f;
                float dist = dot(diff, diff);
                if (dist < min_dist.x) {
                    min_dist.y = min_dist.x;
                    min_dist.x = dist;
                    pivot = pt + neighbor + p;
                } else if (dist < min_dist.y) {
                    min_dist.y = dist;
                }
            }
        }
    }

    return min_dist;
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

float2 hash22(float2 p)
{
    const float2 k = float2(0.3183099, 0.3678794);

    p = p * k + k.yx;
    float2 q = frac(sin(float2(dot(p, float2(127.1, 311.7)),
                               dot(p, float2(269.5, 183.3)))) * 43758.5453);

    return q * 2.0 - 1.0; 
}

float4 quaternionMultiply(float4 q1, float4 q2)
{
    return float4(
        q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y,
        q1.w * q2.y - q1.x * q2.z + q1.y * q2.w + q1.z * q2.x,
        q1.w * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.w,
        q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z
    );
}

float3 rotatePointAroundAxis(float3 p, float3 axis, float angle)
{
    float halfAngle = angle * 0.5;
    float sinHalfAngle = sin(halfAngle);
    float4 rotationQuat = float4(axis * sinHalfAngle, cos(halfAngle));
    float4 rotationQuatConjugate = float4(-rotationQuat.xyz, rotationQuat.w);

    float4 pointQuat = float4(p, 0.0);
    float4 rotatedPointQuat = quaternionMultiply(quaternionMultiply(rotationQuat, pointQuat), rotationQuatConjugate);

    return rotatedPointQuat.xyz;
}

