using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraWobble : MonoBehaviour
{
    private Vector3 og;
    public float rotationSpeed = 1.0f;
    private float t;
    // Start is called before the first frame update
    void Start()
    {
        og = transform.localPosition;
    }

    // Update is called once per frame
    void Update()
    {
        float dx = 0.02f * Mathf.Sin(20.0f * t);
        float dy = -0.02f * Mathf.Cos(20.0f * t);

        Vector3 randWobble = new Vector3(dx, dy, 0);
        transform.localPosition = og + randWobble;

        t += Time.deltaTime;
    }
}
