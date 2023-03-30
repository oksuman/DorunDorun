using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UI : MonoBehaviour
{
    [SerializeField] GameObject maincharacter;
    [SerializeField] GameObject enemy1;
    [SerializeField] int WhenDisappear = 50;
    private GameObject textHeadObject;
    private GameObject textTailObject;
    public Text textHead;
    public Text textTail;

    private void Start()
    {
        textHeadObject = GameObject.FindWithTag("textHeadObject");
        textTailObject = GameObject.FindWithTag("textTailObject");
    }
   
    void Update()
    {
        DistanceMarker();
        textUpdate();
    }
    void DistanceMarker()
    {
        if(enemy1.transform.position.z > maincharacter.transform.position.z + WhenDisappear)
        {
            textHeadObject.SetActive(true);
            if(enemy1.transform.position.x != 101f)
            {
                enemy1.transform.Translate(100f, 0, 0);
            }
        }
        else
        {
            textHeadObject.SetActive(false);
            if(enemy1.transform.position.x == 101f)
            {
                enemy1.transform.Translate(-100f, 0, 0);
            }
        }

        if (enemy1.GetComponent<MoveCharacter>().CheckObjectIsInCamera(enemy1) == false) 
        {
            if(enemy1.transform.position.z < maincharacter.transform.position.z)
            {
                textTailObject.SetActive(true);
            }
        }
        else
        {
            textTailObject.SetActive(false);
        }
    }

    void textUpdate()
    {
        if (enemy1.transform.position.z > maincharacter.transform.position.z + WhenDisappear)
        {
            textHead.text = "¡ã " + Mathf.Floor(enemy1.transform.position.z - maincharacter.transform.position.z) + "m";
        }
        if (enemy1.GetComponent<MoveCharacter>().CheckObjectIsInCamera(enemy1) == false)
        {
            textTail.text = "¡å " + Mathf.Floor(maincharacter.transform.position.z - enemy1.transform.position.z) + "m";
        }
    }
}
