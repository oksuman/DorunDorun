using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveCamera: MonoBehaviour
{
    public GameObject Target;               

    public float offsetX = 0.0f;                
    public float offsetY = 3f;        
    public float offsetZ = -10.0f;    

    public float CameraSpeed = 4.0f; 
    Vector3 TargetPos;                    

    // Update is called once per frame
    void FixedUpdate()
    {
        TargetPos = new Vector3(
            Target.transform.position.x + 1 + offsetX,// 우선 2인 기준 두 캐릭터 사이를 기준으로 
            Target.transform.position.y + offsetY,
            Target.transform.position.z + offsetZ
            );

        // 카메라의 움직임을 부드럽게 하는 함수(Lerp)
        transform.position = Vector3.Lerp(transform.position, TargetPos, Time.deltaTime * CameraSpeed);
    }
}