using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Door : MonoBehaviour
{
    public GameObject door;
    public float speed = 1f;

    private Vector2 xz;

    private void Start() {
        xz = new Vector2(door.transform.position.x, door.transform.position.z);
    }

    // Update is called once per frame
    private void Update() {
        var t = 0.5f * Mathf.Sin(Time.time * speed) + 0.5f;
        door.transform.position = new Vector3(xz.x, Mathf.Lerp(2.55f, 2.95f, t), xz.y);
    }
}