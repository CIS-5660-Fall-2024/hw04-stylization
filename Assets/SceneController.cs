using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class SceneController : MonoBehaviour
{
    public Material[] grassMats;
    public Material[] groundMats;
    public Material[] treeMats;
    public GameObject grassParent;
    public GameObject ground;
    public GameObject tree;
    public GameObject mainLight;

    public Material pixelizeMat;
    public int[] pixelLevel;

    private int currentMatIndex = 0;
    private int currentPixelIndex = 0;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            currentMatIndex = (currentMatIndex + 1) % grassMats.Length;
            ChangeGrassMat(currentMatIndex);
            ChangeTreeMat(currentMatIndex);
        }

        if (Input.GetKeyDown(KeyCode.P))
        {
            currentPixelIndex = (currentPixelIndex + 1) % pixelLevel.Length;
            pixelizeMat.SetFloat("_Detail", pixelLevel[currentPixelIndex]);
        }

        mainLight.transform.Rotate(Vector3.up, Time.deltaTime * 20, Space.World);
    }

    void ChangeGrassMat(int index)
    {
        foreach (Transform child in grassParent.transform)
        {
            child.GetChild(0).GetComponent<MeshRenderer>().material = grassMats[index];
        }
        ground.GetComponent<MeshRenderer>().material = groundMats[index];
    }

    void ChangeTreeMat(int index)
    {
        List<Material> mats = new List<Material>();
        tree.GetComponent<MeshRenderer>().GetMaterials(mats);
        mats[1] = treeMats[index];
        tree.GetComponent<MeshRenderer>().SetMaterials(mats);
    }
}
