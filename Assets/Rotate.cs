using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    [SerializeField] private float rate;

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(new Vector3(0, 360 * rate * Time.deltaTime, 0));
    }
}
