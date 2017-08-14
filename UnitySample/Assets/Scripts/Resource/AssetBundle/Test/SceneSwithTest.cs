using UnityEngine;
using System.Collections;
using AssetBundles ;
using UnityEngine.SceneManagement;

public class SceneSwithTest : MonoBehaviour
{
    // Use this for initialization
    void Start()
    {
        AssetBundleManager.Instance.Initialize();
        //TODO
        LoadSceneBuildSettings.Instance.Init();
        //Scene scene = SceneManager.GetSceneByBuildIndex(0);
        //Debug.Log("______________________scene 1:" + scene.name);

        //Scene scene2 = SceneManager.GetSceneByName("UILogin");
        //Debug.Log("______________________scene UIBattle:" + scene2.path);

        //Scene[] scenes = SceneManager.GetAllScenes();
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void LoadBattle()
    {
        string scenePath = "Scenes/AssetBundleTest/UIBattle";
        StartCoroutine(LaodSceneAsync(scenePath));
    }

    public void LoadLogin()
    {
        string scenePath = "Scenes/AssetBundleTest/UILogin";
        StartCoroutine(LaodSceneAsync(scenePath));
    }

    IEnumerator LaodSceneAsync(string scenePath)
    {
        //float b = Time.realtimeSinceStartup;
        //var  request = ResourceService.Instance.LoadSceneAysnc(scenePath);
        //if (request == null)
        //{
        //    yield break;
        //}

        //yield return request;

        //Debug.Log("___________________________________Scene:" + scenePath + " Load Completed");

        ResourceService.Instance.LoadScene(scenePath);

        //SceneManagerExport.LoadSceneAsyncByName("UILogin",0);

        yield return null;
    }
}
