using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ToggleFilter : MonoBehaviour
{
    [SerializeField] UniversalRendererData feature;

    void Start()
    {
    }

    void Update() {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            feature.rendererFeatures[1].SetActive(true);
            feature.rendererFeatures[2].SetActive(true);
            feature.rendererFeatures[3].SetActive(false);
            feature.rendererFeatures[4].SetActive(false);
        }

        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            feature.rendererFeatures[1].SetActive(false);
            feature.rendererFeatures[2].SetActive(false);
            feature.rendererFeatures[3].SetActive(true);
            feature.rendererFeatures[4].SetActive(true);
        }
    }
}