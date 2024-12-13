using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turntable : MonoBehaviour
{
    public float rotationSpeed = 1.0f;
    public float xRotationConstant = 30.0f; // Constant value for the X-axis

    // Update is called once per frame
    void Update()
    {
        // Get the current Y-axis rotation
        float currentYRotation = this.transform.rotation.eulerAngles.y;

        // Apply the constant X rotation and dynamic Y rotation
        this.transform.rotation = Quaternion.Euler(xRotationConstant, currentYRotation - rotationSpeed * Time.deltaTime, 0);
    }
}
