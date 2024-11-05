using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turntable : MonoBehaviour
{

    public float rotationSpeed = 1.0f;
    private float angleVelocity = 0f;          // For SmoothDamp
    private float ogY;
    private Vector3 currentAngle;

    // Start is called before the first frame update
    void Start()
    {
        ogY = transform.localEulerAngles.y;
        Debug.Log(ogY);
    }

    // Update is called once per frame
    void Update()
    {
        //this.transform.Rotate(0, rotationSpeed * Time.deltaTime, 0);
        float targetAngle = Mathf.Sin(1.5f * Mathf.Sin(Time.time * 0.85f)) * 20.0f;
        currentAngle.y = Mathf.SmoothDampAngle(currentAngle.y, targetAngle, ref angleVelocity, 0.3f);
        transform.localRotation = Quaternion.Euler(0, ogY + currentAngle.y, 0);
    }
}
