using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SonicControl : MonoBehaviour
{
    public List<Material> materials;
    // Start is called before the first frame update
    void Start()
    {
        // add all child materials to the materials array
        UpdateScale();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void TraverseAppendMaterials(Transform t)
    {
        foreach (Transform child in t)
        {
            if (child.GetComponent<Renderer>() != null)
            {
                materials.Add(child.GetComponent<Renderer>().material);
            }
            TraverseAppendMaterials(child);
        }
    }

    void UpdateScale()
    {
        // update all materials in the materials array
        if (materials == null) return;
        foreach (Material m in materials)
        {
            m.SetVector("_ObjectScale", transform.localScale);
            Debug.Log("scale: " + transform.localScale);
        }
    }
}
