using JetBrains.Annotations;
using UnityEngine;

public class ItemHealth : MonoBehaviour
{
  public float rotation = 150;
    void Update()
    {
        transform.Rotate(0, rotation * Time.deltaTime,0);


    }
}
