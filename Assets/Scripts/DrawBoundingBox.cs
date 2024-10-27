using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawBoundingBox : MonoBehaviour
{
    public Color gizmoColor = Color.green; // 包围盒颜色
    private MeshFilter meshFilter;
    [SerializeField]
    private bool drawGizmo = true;
    void Start()
    {
        meshFilter = GetComponent<MeshFilter>();
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
