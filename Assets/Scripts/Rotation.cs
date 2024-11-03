using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightRotation : MonoBehaviour
{
    public float rotationSpeed = 10f;
    public float orientation = 1f;
    // Start is called before the first frame update
    void Start()
    {
       
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.P))
        {
            rotationSpeed += 5f;
        }
        transform.Rotate(0, orientation * rotationSpeed * Time.deltaTime, 0, Space.World);
    }
}
