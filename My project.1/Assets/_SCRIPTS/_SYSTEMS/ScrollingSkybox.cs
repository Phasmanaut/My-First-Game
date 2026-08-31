using UnityEngine;

public class VerticalSkyboxScroll : MonoBehaviour
{
    public float speed = 0.1f;   // how fast the skybox scrolls
    private Material skyboxMaterial;
    private Vector2 offset;

    void Start()
    {
        // Clone the skybox material so you don't modify the original asset
        skyboxMaterial = new Material(RenderSettings.skybox);
        RenderSettings.skybox = skyboxMaterial;
    }

    void Update()
    {
        // Move downward (Y axis)
        offset.y += speed * Time.deltaTime;

        // Apply UV offset
        skyboxMaterial.SetTextureOffset("_MainTex", offset);
    }
}
