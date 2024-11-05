using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turntable : MonoBehaviour
{
    public float angleA = -45f;
    public float angleB = 45f;
    public float rotationSpeed = 1.0f;

    private float t = 0f;
    private bool isIncreasing = true;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (isIncreasing)
        {
            t += Time.deltaTime * rotationSpeed;
            if (t >= 1f)
            {
                t = 1f;
                isIncreasing = false;
            }
        }
        else
        {
            t -= Time.deltaTime * rotationSpeed;
            if (t <= 0f)
            {
                t = 0f;
                isIncreasing = true;
            }
        }

        float angleY = Mathf.Lerp(angleA, angleB, t);
        transform.rotation = Quaternion.Euler(0f, angleY, 0f);
    }
}
