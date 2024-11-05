using UnityEditor;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine;

public class GrassRenderPass : ScriptableRenderPass
{
    private Material material;
    private RenderTextureDescriptor textureDescriptor;
    private RTHandle textureHandle;
    public GrassRenderPass(Material material)
    {
        this.material = material;
        textureDescriptor = new RenderTextureDescriptor(Screen.width,
        Screen.height, RenderTextureFormat.Default, 0);
    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer cmd = CommandBufferPool.Get();
        RTHandle cameraTargetHandle =
        renderingData.cameraData.renderer.cameraColorTargetHandle;



        // Blit from the camera target to the temporary render texture,
        // using the first shader pass.
        Blit(cmd, cameraTargetHandle, textureHandle, material, 0);
        // Blit from the temporary render texture to the camera target,
        // using the second shader pass.
        Blit(cmd, textureHandle, cameraTargetHandle, material, 1);

        //Execute the command buffer and release it back to the pool.
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        //Set the red tint texture size to be the same as the camera target size.
        textureDescriptor.width = cameraTextureDescriptor.width;
        textureDescriptor.height = cameraTextureDescriptor.height;

        //Check if the descriptor has changed, and reallocate the RTHandle if necessary.
        RenderingUtils.ReAllocateIfNeeded(ref textureHandle, textureDescriptor);
    }

    public void Dispose()
    {
#if UNITY_EDITOR
        if (EditorApplication.isPlaying)
        {
            Object.Destroy(material);
        }
        else
        {
            Object.DestroyImmediate(material);
        }
#else
            Object.Destroy(material);
#endif

        if (textureHandle != null) textureHandle.Release();
    }
}