using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PartyDance : MonoBehaviour
{
    public Material material;
    bool isDancing = false;

    private float ogStrength;
    public float speed = 1.0f;
    // Start is called before the first frame update
    void Start()
    {
        ogStrength = 2.13f;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            isDancing = !isDancing;
        }
        if (isDancing)
        {
            var sin = Mathf.Sin(Time.time * speed);
            var scale = 0.5f * (1 + sin);
            var f = Mathf.Lerp(0.5f, 1.2f, scale);
            var xz = Mathf.Lerp(1.0f, 1.2f, scale);
            transform.localScale = new Vector3(xz, f, xz);
            material.SetFloat("_strength", ogStrength);
        }
        else
        {
            material.SetFloat("_strength", 0);
            transform.localScale = Vector3.Lerp(transform.localScale, Vector3.one, 0.2f);
        }
    }
}
