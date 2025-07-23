using System;
using JetBrains.Annotations;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class GameStats : MonoBehaviour
{
    public int playerHealth;
    public int level;
    public int playerCharge;
    public float timer;

    public TextMeshPro healthUI;
    public TextMeshPro timerUI;
    public TextMeshPro levelUI;
    public TextMeshPro chargeUI;
    public TextMeshPro screenText;

    public ParticleSystem cube_die;

    public GameObject enemy_A;


    //ENEMY SPAWNS
    public GameObject spawn0x1,spawn0x2, spawn0x3, spawn0x4, spawn0x5,
                      spawn1x1,spawn1x2, spawn1x3, spawn1x4, spawn1x5, 
                      spawn2x1,spawn2x2, spawn2x3, spawn2x4, spawn2x5,
                      spawn3x1,spawn3x2, spawn3x3, spawn3x4, spawn3x5;


    public GameObject[,] spawn = new GameObject[4,5];

    

    void Start()
    {


        spawn[0,0] = spawn0x1; spawn[0,1] = spawn0x2; spawn[0,2] = spawn0x3; spawn[0,3] = spawn0x4; spawn[0,4] = spawn0x5;
        spawn[1,0] = spawn1x1; spawn[1,1] = spawn1x2; spawn[1,2] = spawn1x3; spawn[1,3] = spawn1x4; spawn[1,4] = spawn1x5;
        spawn[2,0] = spawn2x1; spawn[2,1] = spawn2x2; spawn[2,2] = spawn2x3; spawn[2,3] = spawn2x4; spawn[2,4] = spawn2x5;
        spawn[3,0] = spawn3x1; spawn[3,1] = spawn3x2; spawn[3,2] = spawn3x3; spawn[3,3] = spawn3x4; spawn[3,4] = spawn3x5;




        playerHealth = 3;
        playerCharge = 0;
        level = 0;
        screenText.text = $"SHOOT THE CUBE TO START!";
    }

    
    void Update()
    {
        healthUI.text = $"Health: {playerHealth} ";
        timerUI.text = $"Time: { Convert.ToInt32(timer)} ";
        levelUI.text = $"Level: {level} ";
        chargeUI.text = $"Charge: {playerCharge} ";
        timer += Time.deltaTime;
    }


    public void StartLevelHit()
    {   
        cube_die.Play();
        screenText.text = $" ";
        level++;
        LevelStart(level);

    }


    public void LevelStart(int level){
        if (level == 1)
        {
            Console.WriteLine($"LEVEL STARTED: {level}");
            Instantiate(enemy_A, spawn[1, 0].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[1, 1].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[1, 3].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[1, 4].transform.position, transform.rotation);
            
        }


    }

    public void LevelEnd()
    {


    }












}
