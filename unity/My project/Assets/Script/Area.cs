using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Area : MonoBehaviour
{
    [SerializeField] private float destroyDistance = 70;
    private AreaSpawner areaSpawner;
    private Transform playerTransform;
    public void setUp(AreaSpawner areaSpawner, Transform playerTransform)
    {
        this.areaSpawner = areaSpawner;
        this.playerTransform = playerTransform;
    }

    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if(playerTransform.position.z - transform.position.z >= destroyDistance)
        {
            areaSpawner.SpawnArea();
            Destroy(gameObject);
        }
    }
}
