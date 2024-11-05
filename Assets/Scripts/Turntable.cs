using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turntable : MonoBehaviour
{

    public float rotationSpeed = 1.0f;
    public float maxRotationAngle = 15.0f;
    private float currentAngle = 0.0f;
    private int direction = 1;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //this.transform.Rotate(0, rotationSpeed * Time.deltaTime, 0);

        float deltaAngle = rotationSpeed * Time.deltaTime * direction;
        currentAngle += deltaAngle;

        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (rotationSpeed == 1.0)
            {
                rotationSpeed = 10.0f;

            }else if(rotationSpeed == 10.0f)
            {
                rotationSpeed = 20.0f;
            }
            else
            {
                rotationSpeed = 1.0f;
            }
        }

        if (currentAngle > maxRotationAngle)
        {
            currentAngle = maxRotationAngle;
            direction = -1; 
        }
        else if (currentAngle < -maxRotationAngle)
        {
            currentAngle = -maxRotationAngle;
            direction = 1;
        }

        transform.Rotate(0, deltaAngle, 0);
    }
}
