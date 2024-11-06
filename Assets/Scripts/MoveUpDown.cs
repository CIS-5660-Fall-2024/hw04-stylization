using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class MoveUpDown : MonoBehaviour
{

    public Vector3 translateMax = new Vector3(0, 0.5f, 0);
    public int updateRate = 1000;

    private Vector3 startPos;
    private float time = 0;
    private float halfUpdateRate = 500;
    // Start is called before the first frame update
    void Start()
    {
        time = updateRate / 4.0f;
        startPos = transform.position;
        halfUpdateRate = updateRate / 2.0f;
    }

    float bias(float t, float b)
    {
        return (t / ((((1.0f / b) - 2.0f) * (1.0f - t)) + 1.0f));
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 trans;
        float t;
        if (time < halfUpdateRate)
        {
            t = (halfUpdateRate - time) / halfUpdateRate;
            t = bias(t, 0.7f);
            trans = -translateMax * t + translateMax * (1 - t);
        }
        else{
            t = (time - halfUpdateRate) / halfUpdateRate;
            t = bias(t, 0.7f);
            trans = -translateMax * t + translateMax * (1 - t);
        }
        time++;
        this.transform.position = startPos + trans;
        if (time == updateRate)
        {
            time = 0;
        }
    }
}

