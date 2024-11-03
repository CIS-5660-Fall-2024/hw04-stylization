using UnityEngine;

[System.Serializable]
public class GrassSettings
{
    [Header("Base Map")]
    public Texture2D baseMap;

    [Header("Tessellation Settings")]
    [Range(1, 20)] public float edgeFactor = 20;
    [Range(0, 100)] public float tessMinDist = 30.0f;
    [Range(1, 500)] public float fadeDist = 200.0f;
    [Range(1, 50)] public float heightScale = 10.0f;
    [Range(0.01f, 0.1f)] public float landSpread = 0.02f;

    [Header("Shader Partitioning")]
    public PartitioningMode partitioningMode = PartitioningMode.FractionalEven;
    public OutputTopology outputTopology = OutputTopology.TriangleCCW;

    public enum PartitioningMode { Integer, FractionalEven, FractionalOdd }
    public enum OutputTopology { TriangleCW, TriangleCCW }
}
