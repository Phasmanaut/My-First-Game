using UnityEngine;
using System;
using JetBrains.Annotations;
using Unity.Mathematics;
using UnityEngine.UIElements;
using Unity.VisualScripting;
using UnityEditor.Rendering.Universal.ShaderGraph;


public class Projectile_A : MonoBehaviour
{
    public float projSpeed;

    void Start()
    {
        GameObject player = GameObject.Find("Player");
        transform.LookAt(player.transform);
        transform.SetParent(null);
    }

    void Update()
    {
        transform.Translate(transform.forward * projSpeed * Time.deltaTime, Space.World);
    }

    private void OnCollisionEnter(Collision col)
    {
        if (col.gameObject.tag == "Destroy")
        {
            Destroy(this.gameObject);
        }
        if (col.gameObject.tag == "Player")
        {
            Destroy(this.gameObject);
        }
    }
    
    
}
