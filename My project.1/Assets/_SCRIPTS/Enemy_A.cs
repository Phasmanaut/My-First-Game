using UnityEngine;

public class Enemy_A : MonoBehaviour
{

    void Start()
    {

    }

    public GameObject projectile;

    public float speed = 0.5f;
    public float duration = 3f;
    private float timeElapsed = 0f;
    private bool moveRight = true;

    void Update() //idle movemets
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

            Instantiate(projectile,this.transform);
        }
    }



    void OnCollisionEnter(Collision col)  //killed on hit
    {
        if (col.gameObject.tag == "Player Projectile")
        {

            Destroy(this.gameObject);
        }
    }



















}
