using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class moveLight : MonoBehaviour
{
    public float speed = 1.0f;
    public Vector3 direction = new Vector3(0, 0, 1);
    // Start is called before the first frame update
    void Start()
    {
         
    }

    // Update is called once per frame
    void Update()
    {
        transform.position += direction * speed * Time.deltaTime;
    }
}
