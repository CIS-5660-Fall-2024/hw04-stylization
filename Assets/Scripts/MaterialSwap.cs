using UnityEngine;

public class SwapMaterial : MonoBehaviour
{
    public Material[] materials;
    public Material[] outlineMaterials;
    public Color[] colors;
    public Material[] wingMaterials;
    int index = 0;
    public FullScreenFeature fullScreenPass;
    public FullScreenPassRendererFeature outlineFullScreenPass;
    public GameObject wings;

    private Camera mainCamera;

    void Start()
    {
        if (fullScreenPass == null)
        {
            Debug.LogError("FullScreenPassRendererFeature not found in the current renderer.");
            enabled = false;
            return;
        }
        mainCamera = Camera.main; 
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            index = (index + 1) % materials.Length;
            SwapToNextMaterial(index);
        }
    }

    void SwapToNextMaterial(int index)
    {
        fullScreenPass.SwapMaterial(materials[index % materials.Length]);
        outlineFullScreenPass.passMaterial = outlineMaterials[index % materials.Length];
        MeshRenderer meshRenderer = wings.GetComponent<MeshRenderer>();
        meshRenderer.material = wingMaterials[index % materials.Length];
        mainCamera.backgroundColor = colors[index % materials.Length];
    }
}
