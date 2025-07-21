using Unity.Mathematics;
using UnityEngine;

public class ItemBattery : MonoBehaviour
{




    public float rotation = 150;
    void Update()
    {
        //transform.Rotate(75 * Time.deltaTime,rotation * Time.deltaTime,75 * Time.deltaTime);
        transform.Rotate(0,rotation * Time.deltaTime,0);

    }






}
