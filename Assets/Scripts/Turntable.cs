using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turntable : MonoBehaviour
{
    private bool fast = false;
    public float rotationSpeed = 1.0f;
    public float multiplier = 3.0f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        this.transform.Rotate(0, rotationSpeed * Time.deltaTime, 0);
        if (Input.GetKeyDown(KeyCode.Space))
        {
            fast = !fast;
            if (fast)
                rotationSpeed *= multiplier;
            else 
                rotationSpeed /= multiplier;
        }
    }
}
