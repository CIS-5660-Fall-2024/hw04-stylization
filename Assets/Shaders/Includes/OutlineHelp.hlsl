SAMPLER(sampler_point_clamp);


void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

float3 DecodeNormal(float3 enc)
{
	float kScale = 1.7777;
	float3 nn = enc.xyz * float3(2 * kScale, 2 * kScale, 0) + float3(-kScale, -kScale, 1);
	float g = 2.0 / dot(nn.xyz, nn.xyz);
	float3 n;
	n.xy = g * nn.xy;
	n.z = g - 1;
	return n;
}

void Outline_float(float2 UV, float2 UV0, float OutlineThickness, float DepthSensitivity, float NormalsSensitivity, float ColorSensitivity, float4 OutlineColor, out float4 Out)
{
	float halfScaleFloor = floor(OutlineThickness * 0.5);
	float halfScaleCeil = ceil(OutlineThickness * 0.5);
	float2 Texel = (1.0) / float2(_MainTex_TexelSize.z, _MainTex_TexelSize.w);

	float2 uvSamples[4];
	float depthSamples[4];
	float3 normalSamples[4], colorSamples[4];

	uvSamples[0] = UV - float2(Texel.x, Texel.y) * halfScaleFloor;
	uvSamples[1] = UV + float2(Texel.x, Texel.y) * halfScaleCeil;
	uvSamples[2] = UV + float2(Texel.x * halfScaleCeil, -Texel.y * halfScaleFloor);
	uvSamples[3] = UV + float2(-Texel.x * halfScaleFloor, Texel.y * halfScaleCeil);

	for (int i = 0; i < 4; i++)
	{
		GetDepth_float(uvSamples[i], depthSamples[i]);
		GetNormal_float(uvSamples[i], normalSamples[i]);
		//normalSamples[i] = (normalSamples[i]);
		colorSamples[i] = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvSamples[i]);
	}

    // Depth
	float depthFiniteDifference0 = depthSamples[1] - depthSamples[0];
	float depthFiniteDifference1 = depthSamples[3] - depthSamples[2];
	float edgeDepth = sqrt(pow(depthFiniteDifference0, 2) + pow(depthFiniteDifference1, 2)) * 100;
	float depthThreshold = (1 / DepthSensitivity) * depthSamples[0];
	edgeDepth = edgeDepth > depthThreshold ? 1 : 0;

    // Normals
	float3 normalFiniteDifference0 = normalSamples[1] - normalSamples[0];
	float3 normalFiniteDifference1 = normalSamples[3] - normalSamples[2];
	float edgeNormal = sqrt(dot(normalFiniteDifference0, normalFiniteDifference0) + dot(normalFiniteDifference1, normalFiniteDifference1));
	edgeNormal = edgeNormal > (1 / NormalsSensitivity) ? 1 : 0;

    // Color
	float3 colorFiniteDifference0 = colorSamples[1] - colorSamples[0];
	float3 colorFiniteDifference1 = colorSamples[3] - colorSamples[2];
	float edgeColor = sqrt(dot(colorFiniteDifference0, colorFiniteDifference0) + dot(colorFiniteDifference1, colorFiniteDifference1));
	edgeColor = edgeColor > (1 / ColorSensitivity) ? 1 : 0;

	float edge = max(edgeDepth, max(edgeNormal, edgeColor));

	float4 original = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, UV0);
	original = ((1 - edge) * original) + (edge * lerp(original, OutlineColor, OutlineColor.a));
	Out = ((1 - edge) * original) + (edge * lerp(original, OutlineColor, OutlineColor.a));
}

float random(float2 st)
{ // borrowed from Book of Shaders
	return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
}

void Vignette_float(float Time, float2 UV, out float4 Out) //https://www.shadertoy.com/view/Wdj3zV
{
	UV *= 1.0 - UV.yx;
	float v = UV.x * UV.y * 15.0;
	float t = sin(Time * 20.) * cos(Time * 8. + .5);
	Out = pow(v, 0.4 + t * .05);
}