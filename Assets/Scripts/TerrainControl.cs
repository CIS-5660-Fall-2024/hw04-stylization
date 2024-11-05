using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TerrainControl : MonoBehaviour
{
    [SerializeField]
    private GameObject terrainPrefab;
    [Range(1.0f, 50.0f)]
    [SerializeField]
    private int row = 10;
    [Range(1.0f, 50.0f)]
    [SerializeField]
    private int col = 10;
    [SerializeField]
    ArrayList terrainList = new ArrayList();
    // Start is called before the first frame update
    void Start()
    {
        GenerateTerrain();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void OnValidate()
    {
        GenerateTerrain();
    }

    void GenerateTerrain()
    {
        if (terrainPrefab == null) return;
        foreach (GameObject terrain in this.terrainList)
        {
            if (terrain == null) continue;
            DestroyImmediate(terrain);
            Debug.Log("Destroy terrain: " + terrain.name);
        }
        this.terrainList.Clear();
        Vector3 terrainSize = terrainPrefab.GetComponent<MeshFilter>().sharedMesh.bounds.size;
        Debug.Log("terrainSize: " + terrainSize);
        // create terrains
        for (int i = 0; i < row; i++)
        {
            for (int j = 0; j < col; j++)
            {
                GameObject terrain = Instantiate(terrainPrefab, new Vector3(i * terrainSize.x, 0, j * terrainSize.z), Quaternion.identity);
                terrain.transform.parent = transform;
                terrain.name = "Terrain" + i + j;
                this.terrainList.Add(terrain);
            }
        }
    }
}
