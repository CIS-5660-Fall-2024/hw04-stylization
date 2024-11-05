using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using UnityEngine;

public class RotateObject : MonoBehaviour
{
    public float rotationSpeed = 10.0f; 
    private bool turningLeft = true;
    public float angle = 30.0f;

    void Update()
    {
        Rotate();
    }

    void Rotate()
    {

        float currentAngle = transform.eulerAngles.y;
        currentAngle = currentAngle > 180 ? currentAngle - 360 : currentAngle;
        float targetAngle = turningLeft ? -angle : angle;
        float newAngle = Mathf.MoveTowards(currentAngle, targetAngle, rotationSpeed * Time.deltaTime);
        transform.eulerAngles = new Vector3(0, newAngle, 0);
        if (Mathf.Abs(newAngle - targetAngle) < 0.1f) 
        {
            turningLeft = !turningLeft; 
        }
    }
}
