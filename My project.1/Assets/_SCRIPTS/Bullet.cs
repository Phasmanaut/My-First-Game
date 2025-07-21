using Unity.VisualScripting;
using UnityEngine;
using Vector3 = UnityEngine.Vector3;

public class Bullet : MonoBehaviour
{
    GameObject bullet;
    float speed =10;
   
    void Update()
    {
        transform.Translate(0,speed * Time.deltaTime , 0);
    }

    private void OnCollisionEnter(Collision col){
        if(col.gameObject.tag == "Destroy")
        {
            Destroy (this.gameObject);
        }
    }





}
