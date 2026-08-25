using System;
using System.Collections;
using JetBrains.Annotations;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class GameStats : MonoBehaviour
{
    public int playerHealth;
    public int playerCharge;
    public bool playerAlive;
    
    public int level;
    public int levelEnemies;
    public int points;
    public float timer;
    public bool timerActive;

    public TextMeshPro healthUI;
    public TextMeshPro timerUI;
    public TextMeshPro levelUI;
    public TextMeshPro chargeUI;
    public TextMeshPro pointsUI;
    public TextMeshPro screenText;

    public AudioClip startSound;
    public AudioClip loseSound;
    public AudioClip deathSound;
    public AudioClip Music;
    private AudioSource musicSource;
    public GameObject player;
    private GameObject playerInstance;

    public GameObject pixelguy1;
    public GameObject pixelguy2;
    public GameObject pixelguy3;
    public GameObject pixelguy4;

    public GameObject startCube;
    private GameObject startCubeInstance;
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


        
        playerAlive = true;
        timerActive = false;
        playerHealth = 3;
        playerCharge = 0;
        level = 0;
        points = 0;
        screenText.text = $"SHOOT THE CUBE TO START!";

        playerInstance = Instantiate(player);//instantiates the pref and assigns it so just the instance can be destroyed
        startCubeInstance = Instantiate(startCube);

        //Setup music loop
        musicSource = gameObject.AddComponent<AudioSource>();
        musicSource.volume = 0.3f;
        musicSource.clip = Music;
        musicSource.loop = true;
        musicSource.Play();
        UpdatePixelguy();
    }

    
    void Update()
    {
        healthUI.text = $"Health: {playerHealth} ";
        levelUI.text = $"Level: {level} ";
        chargeUI.text = $"Charge: {playerCharge} ";
        pointsUI.text = $" {points} ";

        if (playerAlive) //stops timer if player dies
        {
            if (timerActive)//makes sure time stops between levels
            {
                timerUI.text = $"Time: {Convert.ToInt32(timer)} ";
                timer += Time.deltaTime;
            }
        }

        
    }


    public void StartLevelHit()
    {
        cube_die.Play();
        screenText.text = $" ";
        level++;
        LevelStart(level);
        AudioSource.PlayClipAtPoint(startSound, transform.position, 5.0f);
        Destroy(startCubeInstance);

    }


    public void LevelStart(int level)
    {
        timerActive = true;

        if (level == 1)
        {
            Console.WriteLine($"LEVEL STARTED: {level}");
            levelEnemies = 4;
            Instantiate(enemy_A, spawn[1, 0].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[1, 1].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[1, 3].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[1, 4].transform.position, transform.rotation);

        }
        else if (level == 2)
        {
            Console.WriteLine($"LEVEL STARTED: {level}");
            levelEnemies = 7;
            Instantiate(enemy_A, spawn[1, 0].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[1, 1].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[1, 3].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[1, 4].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[2, 0].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[2, 2].transform.position, transform.rotation);
            Instantiate(enemy_A, spawn[2, 4].transform.position, transform.rotation);
        }

    }


    public void EnemyDown(int pointGain)
    {
        points += pointGain;
        levelEnemies--;
        if(levelEnemies <= 0)
        {
            LevelEnd();
        }
    }
    public void LevelEnd()
    {
        screenText.text = $"START LEVEL {level + 1} ";
        startCubeInstance = Instantiate(startCube);
        timerActive = false;
    }

    public void PlayerHit()
    {
        CameraShake();

        if (playerHealth > 1)
        {
            playerHealth--;
            UpdatePixelguy();
        }
        else 
        {
            playerHealth = 0;
            EndGame();
            UpdatePixelguy();
            AudioSource.PlayClipAtPoint(loseSound, transform.position, 1.0f);
            AudioSource.PlayClipAtPoint(deathSound, transform.position, 1.0f);
        }
    }

    public void EndGame()
    {
        playerAlive = false;
        Destroy(playerInstance);
        musicSource.Stop();
        screenText.color = Color.red;
        screenText.fontSize = 40;
        screenText.text = $"GAME OVER";

    }

    public void UpdatePixelguy()
    {
            pixelguy1.SetActive(false);
            pixelguy2.SetActive(false);
            pixelguy3.SetActive(false);
            pixelguy4.SetActive(false);

            if(playerHealth ==3)
            {
                pixelguy1.SetActive(true);
            }
            if(playerHealth ==2)
            {
                pixelguy2.SetActive(true);
            }
            if(playerHealth ==1)
            {
                pixelguy3.SetActive(true);
            }
            if(playerHealth ==0)
            {
                pixelguy4.SetActive(true);
            }

    }



    //Camera Shaking below
    void CameraShake()
    {
        StartCoroutine(Shake(0.1f, 0.2f)); // duration, magnitude
    }

    IEnumerator Shake(float duration, float magnitude)
    {
        Camera cam = Camera.main;
        Vector3 originalPos = cam.transform.localPosition;
        float elapsed = 0f;

        while (elapsed < duration)
        {
            float x = UnityEngine.Random.Range(-1f, 1f) * magnitude;
            float y = UnityEngine.Random.Range(-1f, 1f) * magnitude;
            cam.transform.localPosition = originalPos + new Vector3(x, y, 0f);
            elapsed += Time.deltaTime;
            yield return null;
        }

        cam.transform.localPosition = originalPos;
    }

}
