using System;
using FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.EventSystems;
using System.Globalization;


public class CWF : MonoBehaviour
{
    [SerializeField] private GameObject[] characterPrefabs;
    [SerializeField] public RuntimeAnimatorController newController;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }
    public void SetMyName(String message)
    {
        GameObject.Find("MyName").GetComponent<SetMyName>().myName.text = message;
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

    public void SceneChange(String message)
    {
        float value = float.Parse(message, CultureInfo.InvariantCulture.NumberFormat);
        if(value == 1)
        {
            GameObject.FindGameObjectWithTag("SceneController").GetComponent<SceneChange>().sceneChange_RunView();
        }
        else if(value == 0)
        {
            GameObject.FindGameObjectWithTag("SceneController").GetComponent<SceneChange>().sceneChange_MyCharacterView();
        }
        else if(value == 2)
        {
            GameObject.FindGameObjectWithTag("SceneController").GetComponent<SceneChange>().sceneChange_CustomView();
        }
        else if (value == 3)
        {
            GameObject.FindGameObjectWithTag("SceneController").GetComponent<SceneChange>().sceneChange_MakeRoomView();
        }
    }
    public void makeCharacterList()
    {
        for (int i = 0; i < 3; i++)
        {
            string path = "Character/character" + i;
            characterPrefabs[i] = Resources.Load<GameObject>(path);
        }
    }

    public void CharacterSelect(String message)
    {
        int value = int.Parse(message, CultureInfo.InvariantCulture.NumberFormat);
        Destroy(GameObject.FindGameObjectWithTag("MainCharacter"));
        makeCharacterList();
        GameObject clone = null;
        clone = Instantiate(characterPrefabs[value]);
    }

    public void MapSelect(String message)
    {
        int value = int.Parse(message, CultureInfo.InvariantCulture.NumberFormat);
        GameObject.Find("AreaSpawner").GetComponent<AreaSpawner>().myMapNum = value;
        GameObject.Find("AreaSpawner").GetComponent<AreaSpawner>().changeMap();
    }

    public void MakeCharacter(String message)
    {
        float value = float.Parse(message, CultureInfo.InvariantCulture.NumberFormat);
        makeCharacterList();
        GameObject clone = null;
        clone = Instantiate(characterPrefabs[0]);
        clone.transform.Translate(1.5f - value, 0, 0);
        Animator animator = clone.GetComponent<Animator>();
        animator.runtimeAnimatorController = newController;
    }
}
