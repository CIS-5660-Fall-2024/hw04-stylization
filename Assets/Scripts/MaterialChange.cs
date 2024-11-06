using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialSwapper : MonoBehaviour
{
    public Material material1;
    public Material material2;
    private MeshRenderer meshRenderer;
    bool index = true;

    private void Awake()
    {
        meshRenderer = GetComponent<MeshRenderer>();
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (index)
            {
                meshRenderer.material = material2;
            }
            else
            {
                meshRenderer.material = material1;
            }
            index = !index;
        }
    }
}
