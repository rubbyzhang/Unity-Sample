using UnityEngine;
using System.Collections;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

public class AwakeTest : MonoBehaviour
{
    void Awake()
    {
        Debug.Log("___________________________________AwakeTest  Awake");
        SceneManager.sceneLoaded += SceneLoaded;
    }

    void SceneLoaded(Scene scene , LoadSceneMode mode)
    {
        Debug.Log("___________________________________AwakeTest   SceneLoaded");
    }

    // Use this for initialization
    void Start()
    {
        Debug.Log("___________________________________AwakeTest   Start");
    }

    // Update is called once per frame
    void Update()
    {

    }
}
