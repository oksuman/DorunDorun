using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NameView : MonoBehaviour
{
    public GameObject Camera;

    void Update()
    {
        transform.rotation = Camera.transform.rotation;
    }
}