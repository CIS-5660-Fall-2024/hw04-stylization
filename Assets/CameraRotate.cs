using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static UnityEngine.GraphicsBuffer;

public class CameraRotate : MonoBehaviour
{
    public Transform target;
    public float rotateSpeed = 10.0f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void FixedUpdate()
    {
        transform.RotateAround(target.position, Vector3.up, rotateSpeed * Time.fixedDeltaTime);
    }
}
