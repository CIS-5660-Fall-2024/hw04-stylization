using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialSwapper : MonoBehaviour
{
    public Material[] materials;
    private MeshRenderer meshRenderer;
    private Vector3 ogScale;
    private Vector3[] targets;
    private float t = 0.0f;
    private float t2 = 0.0f;
    public float swapSpeed = 0.3f;
    private bool takeMeOut = false;
    int index;
    int swapIndex = 0;

    private bool GetWonky;

    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        ogScale = transform.localScale;

        targets = new Vector3[4];
        targets[0] = ogScale;

        for (int i = 1; i < targets.Length; i++)
        {
            Vector3 target;

            target.x = Random.Range(-1.0f, 1.0f);
            target.y = Random.Range(-1.0f, 1.0f);
            target.z = Random.Range(-1.0f, 1.0f);

            target *= 1.0f;
            target += ogScale;

            targets[i] = target;
        }
    }

    void Wonk()
    {
        if (!GetWonky || !takeMeOut)
        {
            transform.localScale = Vector3.Lerp(transform.localScale, targets[0], Time.deltaTime / (swapSpeed + 0.001f));
        }

        if (t > swapSpeed)
        {
            swapIndex = (swapIndex + 1) % targets.Length;
            t = 0.0f;
        }

        Vector3 goal = targets[swapIndex];

        transform.localScale = Vector3.Lerp(transform.localScale, goal, Time.deltaTime / (swapSpeed + 0.001f));
        t += Time.deltaTime;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space) && materials.Length > 0)
        {
            index = (index + 1) % materials.Length;
            SwapToNextMaterial(index);
        }

        if (Input.GetKeyDown(KeyCode.P))
        {
            GetWonky = !GetWonky;
        }

        if (Input.GetKeyDown(KeyCode.F))
        {
            takeMeOut = !takeMeOut;
        }

        Wonk();
        AutoSwap();
    }

    void AutoSwap()
    {
        if (!takeMeOut || materials.Length == 0) return;

        if (t2 > 0.3f)
        {
            index = (index + 1) % materials.Length;
            SwapToNextMaterial(index);
            t2 = 0.0f;
        }

        t2 += Time.deltaTime;
    }

    void SwapToNextMaterial(int index)
    {
        meshRenderer.material = materials[index % materials.Length];
    }
}
