using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneChange : MonoBehaviour
{
    public void sceneChange_RunView()
    {
        SceneManager.LoadScene("RunView");
    }
    public void sceneChange_MyCharacterView()
    {
        SceneManager.LoadScene("MyCharacterView");
    }
    public void sceneChange_CustomView()
    {
        SceneManager.LoadScene("CustomView");
    }

    public void sceneChange_MakeRoomView()
    {
        SceneManager.LoadScene("MakeRoomView");
    }
}
