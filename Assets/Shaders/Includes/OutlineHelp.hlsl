SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


//void GetNormal_float(float2 uv, out float3 Normal)
//{
//    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
//}

void ChinesePaintingOutline1_float(float noise, float3 scaledir, float3 position_vs, float _MaxOutlineZOffset, float _Outline, out float4 vertexPos)
{
	scaledir = normalize(scaledir);

	float3 viewDir = normalize(position_vs.xyz);
	float3 offset_pos_vs = position_vs.xyz + viewDir * _MaxOutlineZOffset;

	// unity_CameraProjection[1].y = fov/2
	float linewidth = -position_vs.z / unity_CameraProjection[1].y;
	linewidth = sqrt(linewidth);
	vertexPos.xy = offset_pos_vs.xy + scaledir.xy * noise * _Outline * linewidth;
	vertexPos.z = offset_pos_vs.z;
	vertexPos.w = 1.0f;

	float4x4 invMVMatrix = mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V);
	vertexPos = mul(invMVMatrix, vertexPos);
}