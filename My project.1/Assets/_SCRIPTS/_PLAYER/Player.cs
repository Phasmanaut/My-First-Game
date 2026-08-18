using System;
using System.Numerics;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UIElements;
using Quaternion = UnityEngine.Quaternion;
using Vector3 = UnityEngine.Vector3;

public class Player : MonoBehaviour
{
    public float speed = 5f;
    public float rotation = .05f;

    private GameStats gameStats;
    public AudioClip hurt1;
    public AudioClip hurt2;
    public AudioClip hurt3;

    void Start()
    {
        transform.position = new Vector3(0, 0.5f, 0);
        gameStats = GameObject.FindWithTag("GameStats").GetComponent<GameStats>();// gets the script from the object
    }



    public float maxRotationAngle = 20f; // Max rotation in degrees
    public float rotationSpeed = 100f; // Rotation speed
    public float returnSpeed = 200f; // Speed to return to neutral
    private float targetRotationY = 0f; // Target rotation around Y-axis



    void Update()
    {    // Check input keys
        bool right = Input.GetKey(KeyCode.D);
        bool left = Input.GetKey(KeyCode.A);
        Vector3 pos = transform.position;
        


        // Adjust target rotation based on input & changes Player movement
        if (right && !left && pos.x <= 5.75)
        {
            targetRotationY = Mathf.Clamp(targetRotationY - rotationSpeed * Time.deltaTime, -maxRotationAngle, maxRotationAngle);
            pos.x += speed * Time.deltaTime;
        }
        else if (left && !right && pos.x >= -5.75)
        {
            targetRotationY = Mathf.Clamp(targetRotationY + rotationSpeed * Time.deltaTime, -maxRotationAngle, maxRotationAngle);
            pos.x -= speed * Time.deltaTime;
        }
        else
        {
            // Return to neutral smoothly
            targetRotationY = Mathf.MoveTowards(targetRotationY, 0f, returnSpeed * Time.deltaTime);
        }

        // Apply rotation & Movement to the player
        Quaternion targetRotation = Quaternion.Euler(0f, targetRotationY, 0f);
        transform.rotation = targetRotation;
        transform.position = pos;


    }

    void OnCollisionEnter(Collision col)
    {
        if (col.gameObject.CompareTag("EnemyProjectile"))
        {
            gameStats.PlayerHit();
            ExplosionEffect explosion = gameObject.AddComponent<ExplosionEffect>();
            explosion.Explode(ExplosionType.Player);

            AudioClip[] hurtSounds = { hurt1, hurt2, hurt3 };
            AudioClip randomHurt = hurtSounds[UnityEngine.Random.Range(0, hurtSounds.Length)];
            AudioSource.PlayClipAtPoint(randomHurt, gameStats.transform.position, 1.0f);
        }
    }

}
