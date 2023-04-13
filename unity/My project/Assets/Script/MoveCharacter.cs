using System;
using FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.EventSystems;
using System.Globalization;

public class MoveCharacter : MonoBehaviour, IEventSystemHandler
{
    [SerializeField] float coolDown = 3.0f;
    float updateTime = 0.0f;

    [SerializeField] public float moveSpeed = 0f;
    
    [SerializeField]  Vector3 initialPoint = new Vector3(-1, 0, -5);

    public Animator animator;
    // Start is called before the first frame update
    void Start()
    {
       
    }

    // Update is called once per frame
    void Update()
    {
        /*
        if (updateTime > coolDown)
        {
            updateTime = 0.0f;
        }
        else
        {
            updateTime += Time.deltaTime;
        }*/

        this.transform.Translate(0, 0, moveSpeed * Time.deltaTime);

        if(moveSpeed == 0)
        {
            animator.SetFloat("moveSpeed",-1);
        }
        else
        {
            animator.SetFloat("moveSpeed", moveSpeed/6);
        }
    }
    public bool CheckObjectIsInCamera(GameObject target)
    {
        Camera myCamera = GameObject.Find("Main Camera").GetComponent<Camera>();
        Vector3 screenPoint = myCamera.WorldToViewportPoint(target.transform.position);
        bool onScreen = screenPoint.z > 0 && screenPoint.x > 0 && screenPoint.x < 1 && screenPoint.y > 0 && screenPoint.y < 1;

        return onScreen;
    }
}
