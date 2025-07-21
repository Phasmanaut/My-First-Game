using System;
using System.Numerics;
using UnityEngine;
using UnityEngine.UIElements;
using Quaternion = UnityEngine.Quaternion;
using Vector3 = UnityEngine.Vector3;

public class Player : MonoBehaviour
{
    public float speed = 5f;
    public float rotation = .05f;

    void Start()
    {
        transform.position = new Vector3(0, 0.5f, 0); //start position
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
        if (right && !left)
        {
            targetRotationY = Mathf.Clamp(targetRotationY - rotationSpeed * Time.deltaTime, -maxRotationAngle, maxRotationAngle);
            pos.x += speed * Time.deltaTime;
        }
        else if (left && !right)
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


}
