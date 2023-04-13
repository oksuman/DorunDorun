using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AreaSpawner : MonoBehaviour
{
    [SerializeField] private GameObject[] areaPrefabs;
    [SerializeField] private int initialAreaCount = 4;
    [SerializeField] private float zIndex = 50;
    [SerializeField] private float areaCount = 0;
    [SerializeField] private Transform playerTransform;
    [SerializeField] public int myMapNum = 0;
    void Start()
    {
        makeList();
        MakeInitialMap();
    }

    
    void Update()
    {
        
    }

    private void MakeInitialMap()
    {
        for(int i = 0; i < initialAreaCount; i++)
        {
            if(i == 0)
            {
                SpawnArea(false);
            }
            else
            {
                SpawnArea();
            }
        }
    }

    public void SpawnArea(bool isRandom = true)
    {
        GameObject clone = null;

        if(isRandom == false)
        {
            clone = Instantiate(areaPrefabs[myMapNum * 4]);
        }
        else
        {
            int index = Random.Range(0 + myMapNum * 4, 4 + myMapNum * 4);
            clone = Instantiate(areaPrefabs[index]);
        }

        clone.transform.position = new Vector3(0, 0, areaCount * zIndex);

        clone.GetComponent<Area>().setUp(this, playerTransform);

        areaCount++;
    }

    private void makeList()
    {
        for (int i = 0; i < 8; i++)
        {
            string path = "Maps/area" + i;
            areaPrefabs[i] = Resources.Load<GameObject>(path);
        }
    }

    public void changeMap()
    {
        areaCount = 0;
        GameObject[] objectsToDestroy = GameObject.FindGameObjectsWithTag("Area");
        foreach (GameObject obj in objectsToDestroy)
        {
            Destroy(obj);
        }

        MakeInitialMap();
    }
}
