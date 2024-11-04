using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TurntableToggle : MonoBehaviour
{

    public float rotationSpeed = 1.0f;
    bool turning = false;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            turning = !turning;
        }
        if (turning)
        {
            this.transform.Rotate(0, rotationSpeed * Time.deltaTime, 0);
        }
    }
}
