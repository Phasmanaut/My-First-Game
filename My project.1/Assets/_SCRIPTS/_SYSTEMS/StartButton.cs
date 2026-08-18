using System;
using JetBrains.Annotations;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.UIElements;

public class StartButton : MonoBehaviour
{
    private GameStats gameStats;
    public GameObject startCube;


    void Start()
    {
        gameStats = GameObject.FindWithTag("GameStats").GetComponent<GameStats>();// gets the script from the object
        transform.position = new Vector3(0, 4f ,0);
    }
    

    bool bl = true;
    void Update()
    {
        //Fancy Rotate & Sizer
        Vector3 scale = transform.localScale;

        float rotate = 45 * Time.deltaTime;
        transform.Rotate(rotate * 2, rotate, rotate * 3);

        if (scale.x < .6 && bl)
        {
            transform.localScale += scale * Time.deltaTime * .5f;
            if (scale.x >= .5) { bl = false; scale.x = .5f; }
        }

        if (scale.x > .2 && !bl)
        {
            transform.localScale -= scale * Time.deltaTime * .5f;
            if (scale.x <= .3) { bl = true; scale.x = .3f; }
        }

    }


    void OnCollisionEnter(Collision col)
    {
        if (col.gameObject.tag == "Player Projectile")
        {
            gameStats.StartLevelHit();
            Destroy(this.startCube);
        }
    }


    










}
