using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class InjectRenderPass : MonoBehaviour
{
    [SerializeField] private GrassSettings settings;
    [SerializeField] private Material material;
    private GrassRenderPass grassRenderPass;

    private void OnEnable()
    {
        Material materialInstance = new Material(material);
        materialInstance.SetTexture("_BaseMap", settings.baseMap);
        materialInstance.SetFloat("_EdgeFactor", settings.edgeFactor);
        materialInstance.SetFloat("_TessMinDist", settings.tessMinDist);
        materialInstance.SetFloat("_FadeDist", settings.fadeDist);
        materialInstance.SetFloat("_HeightScale", settings.heightScale);
        materialInstance.SetFloat("_LandSpread", settings.landSpread);
        materialInstance.SetFloat("_PartitioningMode", (float)settings.partitioningMode);
        materialInstance.SetFloat("_OutputTopology", (float)settings.outputTopology);

        grassRenderPass = new GrassRenderPass(materialInstance);

        RenderPipelineManager.beginCameraRendering += OnBeginCameraRendering;
    }

    private void OnDisable()
    {
        RenderPipelineManager.beginCameraRendering -= OnBeginCameraRendering;
        grassRenderPass.Dispose();
    }

    private void OnBeginCameraRendering(ScriptableRenderContext context, Camera camera)
    {
        var cameraData = camera.GetUniversalAdditionalCameraData();
        if (cameraData != null)
        {
            cameraData.scriptableRenderer.EnqueuePass(grassRenderPass);
        }
    }
}
