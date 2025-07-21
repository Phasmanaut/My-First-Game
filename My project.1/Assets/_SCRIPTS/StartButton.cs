using System;
using JetBrains.Annotations;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.UIElements;

public class StartButton : MonoBehaviour
{
    void Start()
    {


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


    public GameStats trigger;
    void OnCollisionEnter(Collision col)
    {
        if (col.gameObject.tag == "Player Projectile")
        {
            trigger.StartLevelHit();
            Destroy(this.gameObject);
        }
    }


    










}
