using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureSwitcher : MonoBehaviour
{
    // List of materials to choose from
    public List<Material> materials;

    void Update()
    {
        // Check if the space key was pressed
        if (Input.GetKeyDown(KeyCode.Space))
        {
            // Get all child objects with names ending in ".mesh" recursively
            List<Renderer> meshRenderers = new List<Renderer>();
            GetMeshRenderersRecursively(transform, meshRenderers);

            // Apply a random material to each renderer
            foreach (Renderer renderer in meshRenderers)
            {
                if (materials.Count > 0)
                {
                    // Select a random material from the list
                    Material randomMaterial = materials[Random.Range(0, materials.Count)];
                    renderer.material = randomMaterial;
                }
                else
                {
                    Debug.LogWarning("No materials assigned to TextureSwitcher.");
                }
            }
        }
    }

    /// <summary>
    /// Recursively searches for child objects with names ending in ".mesh" and adds their Renderers to the list.
    /// </summary>
    /// <param name="parent">The parent transform to start searching from.</param>
    /// <param name="renderers">The list to populate with found Renderers.</param>
    void GetMeshRenderersRecursively(Transform parent, List<Renderer> renderers)
    {
        foreach (Transform child in parent)
        {
            // Check if the child's name ends with ".mesh"
            if (child.name.EndsWith(".mesh"))
            {
                Renderer renderer = child.GetComponent<Renderer>();
                if (renderer != null)
                {
                    renderers.Add(renderer);
                }
            }

            // Recursively search this child's children
            if (child.childCount > 0)
            {
                GetMeshRenderersRecursively(child, renderers);
            }
        }
    }
}
