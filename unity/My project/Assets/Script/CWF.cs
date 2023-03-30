using System;
using FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.EventSystems;
using System.Globalization;


public class CWF : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void SetMySpeed(String message)
    {
        float value = float.Parse(message, CultureInfo.InvariantCulture.NumberFormat);
        GameObject.Find("MainCharacter").GetComponent<MoveCharacter>().moveSpeed = value;
    }

    public void SetEnemySpeed(String message)
    {
        float value = float.Parse(message, CultureInfo.InvariantCulture.NumberFormat);
        GameObject.Find("SubCharacter").GetComponent<MoveCharacter>().moveSpeed = value;
    }

    public void SceneChage(String message)
    {
        float value = float.Parse(message, CultureInfo.InvariantCulture.NumberFormat);
        if(value == 1)
        {
            GameObject.FindGameObjectWithTag("SceneController").GetComponent<SceneChange>().sceneChange();
        }
    }
}
