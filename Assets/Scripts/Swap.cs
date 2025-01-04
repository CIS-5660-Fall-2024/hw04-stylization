using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Reflection;

public class Swap : MonoBehaviour
{
    public Material[] materials;
    private int index = 0;
    private FullScreenFeature fullScreenFeature;

    void Start()
    {
        var urpAsset = GraphicsSettings.currentRenderPipeline as UniversalRenderPipelineAsset;
        if (urpAsset != null)
        {
            Debug.Log("URP Asset found.");

            var scriptableRenderer = urpAsset.scriptableRenderer as ScriptableRenderer;

            if (scriptableRenderer != null)
            {
                Debug.Log("ScriptableRenderer found.");
                var rendererFeaturesField = typeof(ScriptableRenderer).GetField("m_RendererFeatures", BindingFlags.NonPublic | BindingFlags.Instance);
                var rendererFeatures = rendererFeaturesField?.GetValue(scriptableRenderer) as System.Collections.Generic.List<ScriptableRendererFeature>;

                if (rendererFeatures != null)
                {
                    foreach (var feature in rendererFeatures)
                    {
                        if (feature is FullScreenFeature)
                        {
                            fullScreenFeature = feature as FullScreenFeature;
                            Debug.Log("FullScreenFeature found and assigned.");
                            break;
                        }
                    }
                }
                else
                {
                    Debug.LogError("Renderer Features not found.");
                }
            }
            else
            {
                Debug.LogError("ScriptableRenderer not found in the URP Asset.");
            }
        }
        else
        {
            Debug.LogError("URP Asset not found.");
        }

    }

    void Update()
    {
        if (fullScreenFeature != null && Input.GetKeyDown(KeyCode.Space))
        {
            index = (index + 1) % materials.Length;
            fullScreenFeature.SetMaterial(materials[index]);
            Debug.Log($"Material swapped.");
        }
    }
}
