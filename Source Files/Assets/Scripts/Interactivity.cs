using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interactivity : MonoBehaviour
{
    public Turntable turntable;
    private bool isScary = false;
    public Material postProcess;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            isScary = !isScary;
            //var postProcess = Materials.Load<Material>("Post Process Outlines");
            if (postProcess == null)
            {
                Debug.LogError("Post Process Outlines material not found in Resources folder!");
                return;
            }

            if (isScary) {
                postProcess.SetInt("_Scary", 1);
                turntable.rotationSpeed = -200;
            }
            else {
                postProcess.SetInt("_Scary", 0);
                turntable.rotationSpeed = 10.0f;
            }
        }
    }
}
