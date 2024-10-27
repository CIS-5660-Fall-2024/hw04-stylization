using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GrassBehavior : MonoBehaviour
{
    [Range(0.0f, 50.0f)]
    [SerializeField]
    private float heightScale = 24.5f;
    [Range(0.0f, 0.3f)]
    [SerializeField]
    private float landSpread = 0.1f;
    [SerializeField]
    private Material grassMaterial;
    [SerializeField]
    private Material floorMaterial;
    public Color gizmoColor = Color.green; // 包围盒颜色
    private MeshFilter meshFilter;
    [SerializeField]
    private bool drawGizmo = true;
    // Start is called before the first frame update
    void Start()
    {
        transform.localScale = new Vector3(transform.localScale.x, 1.0f, transform.localScale.z);
        UpdateBoundingBox();
        UpdateMaterial();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void UpdateMaterial()
    {
        grassMaterial.SetFloat("_HeightScale", heightScale);
        grassMaterial.SetFloat("_LandSpread", landSpread);
        floorMaterial.SetFloat("_HeightScale", heightScale);
        floorMaterial.SetFloat("_LandSpread", landSpread);
    }

    void UpdateBoundingBox()
    {
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        if (meshFilter == null) return;

        // 获取原始包围盒并扩展Y轴
        Bounds bounds = meshFilter.sharedMesh.bounds;
        bounds.extents = new Vector3(bounds.extents.x, heightScale, bounds.extents.z);
        Debug.Log("bounds.extents: " + bounds.extents);
        // 更新Mesh的包围盒
        meshFilter.sharedMesh.bounds = bounds;
    }

    void OnValidate()
    {
        UpdateBoundingBox();
        UpdateMaterial();
    }

    void OnDrawGizmos()
    {
        if (!drawGizmo) return;
        if (meshFilter == null)
            meshFilter = GetComponent<MeshFilter>();

        if (meshFilter != null && meshFilter.sharedMesh != null)
        {
            Gizmos.color = gizmoColor;

            // 获取当前包围盒并转换到世界坐标系
            Bounds bounds = meshFilter.sharedMesh.bounds;
            Matrix4x4 matrix = transform.localToWorldMatrix;
            Gizmos.matrix = matrix;

            // 在Scene视图中绘制包围盒
            Gizmos.DrawWireCube(bounds.center, bounds.size);
        }
    }
}
