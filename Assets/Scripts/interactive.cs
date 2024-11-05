using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class interactive : MonoBehaviour
{
    public Material[] materials;
    private MeshRenderer meshRenderer;
    int index;
    public float rotation;
    public Light light;
    // Start is called before the first frame update
    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        rotation = 4.0f;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            index = (index + 1) % materials.Length;
            SwapToNextMaterial(index);
        }

        if (Input.GetKey(KeyCode.A))
        {
            if (light != null)
            {
                light.transform.Rotate(Vector3.up, -rotation, Space.World);
            }
        }

        if (Input.GetKey(KeyCode.D))
        {
            if (light != null)
            {
                light.transform.Rotate(Vector3.up, rotation, Space.World);
            }
        }
    }
    void SwapToNextMaterial(int index)
    {
        meshRenderer.material = materials[index % materials.Length];
    }
}
