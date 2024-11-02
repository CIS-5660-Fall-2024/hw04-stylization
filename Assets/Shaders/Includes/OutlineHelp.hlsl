SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

void GetCrossSampleUVs_float(float2 uv, float2 texelSize, float offsetMultiplier,
	out float2 uvOri, out float2 uvTR, out float2 uvBL, out float2 uvTL, out float2 uvBR)
{
	uvOri = uv;
	uvTR = uv + float2(texelSize.x, texelSize.y) * offsetMultiplier;
	uvBL = uv - float2(texelSize.x, texelSize.y) * offsetMultiplier;
	uvTL = uv + float2(-texelSize.x, texelSize.y) * offsetMultiplier;
	uvBR = uv - float2(-texelSize.x, texelSize.y) * offsetMultiplier;
}

void GetNormalCrossSample_float(float2 uvTR, float2 uvBL, float2 uvTL, float2 uvBR,
	out float normalDiff)
{
	float3 norTR, norBL, norTL, norBR;
	
	norTR = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uvTR).rgb;
	norBL = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uvBL).rgb;
	norTL = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uvTL).rgb;
	norBR = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uvBR).rgb;

	float3 normalDiff1 = norTR - norBL;
	float3 normalDiff2 = norTL - norBR;
	normalDiff = dot(normalDiff1, normalDiff1) + dot(normalDiff2, normalDiff2);
}

void GetDepthCrossSample_float(float2 uvTR, float2 uvBL, float2 uvTL, float2 uvBR,
	out float depthDiff)
{
	float depthTR, depthBL, depthTL, depthBR;

	depthTR = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uvTR);
	depthBL = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uvBL);
	depthTL = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uvTL);
	depthBR = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uvBR);

	float depthDiff1 = depthTR - depthBL;
	float depthDiff2 = depthTL - depthBR;
	depthDiff = 10.f * (abs(depthDiff1) + abs(depthDiff2));
}