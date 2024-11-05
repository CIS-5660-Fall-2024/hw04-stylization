using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialSwapper : MonoBehaviour
{
    public Material materia11;
    public Material materia12;

    private MeshRenderer meshRenderer;
    private bool isFirstMat;

    private void Awake()
    {
        meshRenderer = GetComponent<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        if(!meshRenderer)
        {
            return;
        }
        if(Input.GetKeyDown(KeyCode.Space))
        {
            meshRenderer.material = isFirstMat ? materia11 : materia12;
            isFirstMat = !isFirstMat;
        }
    }
}
