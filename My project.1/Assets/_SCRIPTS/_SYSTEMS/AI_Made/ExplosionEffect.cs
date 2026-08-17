using UnityEngine;

public class CubeParticle : MonoBehaviour
{
    private float lifetime;
    private float elapsed = 0f;
    private Vector3 startScale;
    private Renderer rend;

    public void Initialize(float duration)
    {
        lifetime = duration;
        startScale = transform.localScale;
        rend = GetComponent<Renderer>();
    }

    void Update()
    {
        elapsed += Time.deltaTime;
        float t = elapsed / lifetime;

        transform.localScale = startScale * (1f - t);

        if (elapsed >= lifetime)
        {
            Destroy(gameObject);
        }
    }
}

public class FlameParticle : MonoBehaviour
{
    private float lifetime;
    private float elapsed = 0f;
    private Vector3 startScale;
    private Renderer rend;

    public void Initialize(float duration)
    {
        lifetime = duration;
        startScale = transform.localScale;
        rend = GetComponent<Renderer>();
    }

    void Update()
    {
        elapsed += Time.deltaTime;
        float t = elapsed / lifetime;

        Color flickerColor = Color.Lerp(Color.red, new Color(1, 0.5f, 0), Mathf.Sin(elapsed * 10f) * 0.5f + 0.5f);
        rend.material.color = flickerColor;
        rend.material.SetColor("_EmissionColor", flickerColor * 2f);

        transform.localScale = startScale * (1f - t);

        if (elapsed >= lifetime)
        {
            Destroy(gameObject);
        }
    }
}

public enum ExplosionType
{
    Standard,      // Blue and magenta
    Player,        // Red, blue, grey
    Fire           // Just flames
}

public class ExplosionEffect : MonoBehaviour
{
    public int particleCount = 10;
    public float explosionForce = 2f;
    public float particleLifetime = 0.5f;

    public void Explode(ExplosionType type = ExplosionType.Standard)
    {
        switch (type)
        {
            case ExplosionType.Standard:
                StandardExplosion();
                break;
            case ExplosionType.Player:
                PlayerExplosion();
                break;
            case ExplosionType.Fire:
                FireExplosion();
                break;
        }
    }

    private void StandardExplosion()
    {
        for (int i = 0; i < particleCount; i++)
        {
            bool isWhite = Random.value < 0.2f;

            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.transform.position = transform.position;
            cube.transform.localScale = Vector3.one * 0.15f;

            Collider col = cube.GetComponent<Collider>();
            Destroy(col);

            Rigidbody rb = cube.AddComponent<Rigidbody>();
            rb.mass = 0.1f;
            rb.useGravity = false;

            Vector3 randomDir = Random.onUnitSphere;
            rb.linearVelocity = randomDir * explosionForce;

            Renderer renderer = cube.GetComponent<Renderer>();
            Color glowColor = isWhite ? Color.white : (Random.value > 0.5f ? new Color(0, 0.5f, 1) : new Color(1, 0, 1));
            renderer.material.color = glowColor;
            renderer.material.SetColor("_EmissionColor", glowColor * 2f);
            renderer.material.EnableKeyword("_EMISSION");

            CubeParticle cp = cube.AddComponent<CubeParticle>();
            cp.Initialize(particleLifetime);
        }

        SpawnFlames();
    }

    private void PlayerExplosion()
    {
        for (int i = 0; i < particleCount; i++)
        {
            float rand = Random.value;
            Color glowColor;

            if (rand < 0.6f)
            {
                glowColor = Color.red;
            }
            else if (rand < 0.7f)
            {
                glowColor = Color.blue;
            }
            else
            {
                glowColor = Color.gray;
            }

            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.transform.position = transform.position;
            cube.transform.localScale = Vector3.one * 0.15f;

            Collider col = cube.GetComponent<Collider>();
            Destroy(col);

            Rigidbody rb = cube.AddComponent<Rigidbody>();
            rb.mass = 0.1f;
            rb.useGravity = false;

            Vector3 randomDir = Random.onUnitSphere;
            rb.linearVelocity = randomDir * explosionForce;

            Renderer renderer = cube.GetComponent<Renderer>();
            renderer.material.color = glowColor;
            renderer.material.SetColor("_EmissionColor", glowColor * 2f);
            renderer.material.EnableKeyword("_EMISSION");

            CubeParticle cp = cube.AddComponent<CubeParticle>();
            cp.Initialize(particleLifetime);
        }

        SpawnFlames();
    }

    private void FireExplosion()
    {
        SpawnFlames();
    }

    private void SpawnFlames()
    {
        int flameCount = 8;
        for (int i = 0; i < flameCount; i++)
        {
            GameObject flame = GameObject.CreatePrimitive(PrimitiveType.Cube);
            flame.transform.position = transform.position;
            flame.transform.localScale = Vector3.one * 0.08f;

            Collider col = flame.GetComponent<Collider>();
            Destroy(col);

            Rigidbody rb = flame.AddComponent<Rigidbody>();
            rb.mass = 0.1f;
            rb.useGravity = false;

            Vector3 randomDir = Random.onUnitSphere;
            rb.linearVelocity = randomDir * 5f;

            Renderer renderer = flame.GetComponent<Renderer>();
            renderer.material.color = Color.red;
            renderer.material.SetColor("_EmissionColor", Color.red * 2f);
            renderer.material.EnableKeyword("_EMISSION");

            FlameParticle fp = flame.AddComponent<FlameParticle>();
            fp.Initialize(0.3f);
        }
    }
}