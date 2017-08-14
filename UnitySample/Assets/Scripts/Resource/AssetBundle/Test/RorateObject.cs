using System;
using UnityEngine ;


class RorateObject : MonoBehaviour
{
    void Start()
    {
        
    }

    private float angle = 0;
    void Update()
    {
        angle += Time.deltaTime*50;
        gameObject.transform.localEulerAngles = new Vector3(angle,0,0);
    }
}