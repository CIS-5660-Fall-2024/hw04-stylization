using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/*public Material[] materials;
private MeshRenderer meshRenderer;
int index;*/

public class Interaction : MonoBehaviour
{
    public Material[] materials;
    private int index;
    private MeshRenderer meshRenderer;
    // Start is called before the first frame update
    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        index = 0;
        if (materials.Length > 0)
        {
            meshRenderer.material = materials[index];
        }
        else
        {
            Debug.LogWarning("No materials assigned to MaterialSwitcher!");
        }
    }

    // Update is called once per frame
    void Update()
    {
       if (Input.GetKeyDown(KeyCode.Space))
        {
            index = (index + 1) % materials.Length;
            SwapToNextMaterial(index);
        }
    }
    void SwapToNextMaterial(int index)
    {
       meshRenderer.material = materials[index % materials.Length];
    }
}
