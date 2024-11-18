using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Main : MonoBehaviour
{
    public MeshRenderer background;

    public Texture2D bg;
    public Texture2D blackspace;
    public Turntable turntable;

    public MeshRenderer door;
    public MeshRenderer doorFrame;
    public MeshRenderer laptop;

    public Material doorWhite;
    public Material doorGray;
    public Material doorSelected;

    private bool Dark;

    // Update is called once per frame
    private void Update() {
        if (Input.GetKeyDown(KeyCode.Space)) {
            Dark = !Dark;

            var fullscreen = Resources.Load<Material>("Full Screen Feature Mat");

            if (Dark) {
                fullscreen.SetInt("_Dark", 1);
                background.material.SetInt("_Dark", 1);
                background.material.SetTexture("_Image", blackspace);
                turntable.rotationSpeed = -300;
                door.material = doorSelected;
                doorFrame.material = doorSelected;
                laptop.materials[0].SetInt("_Dark", 1);
            }
            else {
                fullscreen.SetInt("_Dark", 0);
                background.material.SetInt("_Dark", 0);
                background.material.SetTexture("_Image", bg);
                turntable.rotationSpeed = 30;
                door.material = doorWhite;
                doorFrame.material = doorGray;
                laptop.materials[0].SetInt("_Dark", 0);
            }
        }
    }

    private void OnDestroy() {
        var fullscreen = Resources.Load<Material>("Full Screen Feature Mat");
        fullscreen.SetInt("_Dark", 0);
    }
}