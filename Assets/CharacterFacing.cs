using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterFacing : MonoBehaviour
{
    // Update is called once per frame
    public Material avatarMaterial;
    void Update()
    {
        Vector3 forwardVector = transform.forward;
        Vector3 rightVector = transform.right;

        // Pass these vectors to the material
        avatarMaterial.SetVector("_FaceForward", forwardVector);
        avatarMaterial.SetVector("_FaceRight", rightVector);
    }
}
