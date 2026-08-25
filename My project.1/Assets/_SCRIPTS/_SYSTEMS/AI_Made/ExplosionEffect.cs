using UnityEngine;

public class CubeParticle : MonoBehaviour
{
    private float lifetime;
    private float elapsed = 0f;
    private Vector3 startScale;

    public void Initialize(float duration)
    {
        lifetime = duration;
        startScale = transform.localScale;
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

        Color flickerColor = Color.Lerp(Color.red, new Color(2, 1, 0), Mathf.Sin(elapsed * 10f) * 0.5f + 0.5f);
        rend.material.color = flickerColor;

        transform.localScale = startScale * (1f - t);

        if (elapsed >= lifetime)
        {
            Destroy(gameObject);
        }
    }
}

public enum ExplosionType
{
    Standard,
    Player,
    Fire
}

public class ExplosionEffect : MonoBehaviour
{
    public int particleCount = 10;
    public float explosionForce = 2f;
    public float particleLifetime = 0.5f;

    private void StandardExplosion()
    {
        for (int i = 0; i < particleCount; i++)
        {
            bool isWhite = Random.value < 0.2f;

            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.transform.position = transform.position;
            cube.transform.localScale = Vector3.one * 0.15f;
            cube.layer = LayerMask.NameToLayer("ExplosionParticles");

            Collider col = cube.GetComponent<Collider>();
            Destroy(col);

            Rigidbody rb = cube.AddComponent<Rigidbody>();
            rb.mass = 0.1f;
            rb.useGravity = false;

            Vector3 randomDir = Random.onUnitSphere;
            rb.linearVelocity = randomDir * explosionForce;

            Color glowColor = isWhite ? new Color(2, 2, 2) : (Random.value > 0.5f ? new Color(0, 1, 2) : new Color(2, 0, 2));

            Renderer renderer = cube.GetComponent<Renderer>();
            Shader unlit = Shader.Find("Unlit/Color");
            renderer.material.shader = unlit;
            renderer.material.color = glowColor;

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
                glowColor = new Color(2, 0, 0);
            else if (rand < 0.7f)
                glowColor = new Color(0, 0, 2);
            else
                glowColor = new Color(1.5f, 1.5f, 1.5f);

            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.transform.position = transform.position;
            cube.transform.localScale = Vector3.one * 0.15f;
            cube.layer = LayerMask.NameToLayer("ExplosionParticles");

            Collider col = cube.GetComponent<Collider>();
            Destroy(col);

            Rigidbody rb = cube.AddComponent<Rigidbody>();
            rb.mass = 0.1f;
            rb.useGravity = false;

            Vector3 randomDir = Random.onUnitSphere;
            rb.linearVelocity = randomDir * explosionForce;

            Renderer renderer = cube.GetComponent<Renderer>();
            Shader unlit = Shader.Find("Unlit/Color");
            renderer.material.shader = unlit;
            renderer.material.color = glowColor;

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
            flame.layer = LayerMask.NameToLayer("ExplosionParticles");

            Collider col = flame.GetComponent<Collider>();
            Destroy(col);

            Rigidbody rb = flame.AddComponent<Rigidbody>();
            rb.mass = 0.1f;
            rb.useGravity = false;

            Vector3 randomDir = Random.onUnitSphere;
            rb.linearVelocity = randomDir * 5f;

            Renderer renderer = flame.GetComponent<Renderer>();
            Shader unlit = Shader.Find("Unlit/Color");
            renderer.material.shader = unlit;
            renderer.material.color = new Color(3, 1.5f, 0);

            FlameParticle fp = flame.AddComponent<FlameParticle>();
            fp.Initialize(0.3f);
        }
    }

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
}