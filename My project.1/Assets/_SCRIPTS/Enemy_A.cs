using UnityEngine;

public class Enemy_A : MonoBehaviour
{

    void Start()
    {

    }


    public float speed = 0.5f;
    public float duration = 3f;
    private float timeElapsed = 0f;
    private bool moveRight = true;

    void Update()
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
        }
    }



    void OnCollisionEnter(Collision col)
    {
        if (col.gameObject.tag == "Player Projectile")
        {

            Destroy(this.gameObject);
        }
    }



















}
