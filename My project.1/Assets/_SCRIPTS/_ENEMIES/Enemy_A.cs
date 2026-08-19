using UnityEngine;

public class Enemy_A : MonoBehaviour
{

    
    private GameStats gameStats;
    public GameObject projectile;
    public GameObject floatingPoints;
    public AudioClip death;
    public AudioClip shoot;

    public int points = 50;
    public float speed = 0.5f;
    public float duration = 3f;
    private float timeElapsed = 0f;
    private bool moveRight = true;

    void Start()
    {
        gameStats = GameObject.FindWithTag("GameStats").GetComponent<GameStats>();

        
        ExplosionEffect explosion = gameObject.AddComponent<ExplosionEffect>(); //spawn in effect
        explosion.Explode(ExplosionType.Standard);
    }
    void Update() //idle movemets
    {
        if (gameStats.playerAlive) //stops all if player is dead
        {
            timeElapsed += Time.deltaTime;

            if (moveRight)
            {
                transform.Translate(speed * Time.deltaTime, 0, 0);
            }
            else
            {
                transform.Translate(-speed * Time.deltaTime, 0, 0);
            }

            if (timeElapsed >= duration)
            {
                moveRight = !moveRight; // Swap direction
                timeElapsed = 0f; // Reset timer     
                Instantiate(projectile, this.transform);
                AudioSource.PlayClipAtPoint(shoot, transform.position, 1.0f);
            }
        }
    }



    void OnCollisionEnter(Collision col)  //killed on hit
    {
        if (col.gameObject.tag == "Player Projectile")
        {
            Instantiate(floatingPoints, transform.position, Quaternion.identity).GetComponent<FloatingPoints>().pointWorth = points;
            AudioSource.PlayClipAtPoint(death, transform.position, 1.0f);
            ExplosionEffect explosion = gameObject.AddComponent<ExplosionEffect>();
            explosion.Explode(ExplosionType.Standard);
            gameStats.EnemyDown(points);
            Destroy(this.gameObject);
        }
    }



















}
