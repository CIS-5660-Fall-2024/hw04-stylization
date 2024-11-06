using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class moveLight1 : MonoBehaviour
{
    public float speed = 1.0f;
    public float currentXRotation = 80.0f;
    // Start is called before the first frame update
    void Start()
    {
         
    }

    // Update is called once per frame
    void Update()
    {
        currentXRotation += Time.deltaTime * speed;
        transform.rotation = Quaternion.Euler(currentXRotation, transform.rotation.eulerAngles.y, transform.rotation.eulerAngles.z);
    }
}
