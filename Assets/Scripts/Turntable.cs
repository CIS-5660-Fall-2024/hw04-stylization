using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turntable : MonoBehaviour
{

    public float rotationSpeed = 1.0f;
    public Material[] materials;
    private MeshRenderer meshRenderer;
    int index;
    public GameObject wither, wolf;
    public Material postMat;
    bool hull = false;
    public GameObject[] hulls;

    void Start()
    {
        SwapToNextMaterial(0);
        hull = postMat.GetFloat("_Thickness_1") == 0;
    }

    void Update()
    {
        this.transform.Rotate(0, rotationSpeed * Time.deltaTime, 0);

        if (Input.GetKeyDown(KeyCode.Space))
        {
            index = (index + 1) % materials.Length;
            SwapToNextMaterial(index);
        }
        if(Input.GetKeyDown(KeyCode.E))
        {
            if (!hull)
            {
                postMat.SetFloat("_Thickness_1", 0);
                foreach (GameObject g in hulls)
                {
                    g.SetActive(true);
                }
                hull = true;
            }
            else
            {
                postMat.SetFloat("_Thickness_1", 1);
                foreach (GameObject g in hulls)
                {
                    g.SetActive(false);
                }
                hull = false;
            }
        }
    }

    void SwapToNextMaterial(int index)
    {
        if(index<2)
        {
            wolf.SetActive(true);
            wither.SetActive(false);
            meshRenderer = wolf.GetComponent<MeshRenderer>();
        }
        else
        {
            wolf.SetActive(false);
            wither.SetActive(true);
            meshRenderer = wither.GetComponent<MeshRenderer>();
        }
        meshRenderer.material = materials[index % materials.Length];

    }

}
