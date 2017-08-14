using System.Collections.Generic;
using System.Collections ;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using AssetBundles ;

public class AsyncLoadSceneTest : MonoBehaviour
{
    public Text TXT;
    public Canvas Canvas;

    void Awake()
    {
        AssetBundleManager.Instance.Initialize();
        DontDestroyOnLoad(gameObject);
        DontDestroyOnLoad(Canvas.gameObject);
        DontDestroyOnLoad(Canvas.worldCamera.gameObject);
        //Canvas.worldCamera.clearFlags = CameraClearFlags.Nothing;
    }

    public void LoadLobbyFromAbasync()
    {
        //SceneManager.LoadScene("UILogin");
        //string scenePath = "Scenes/AssetBundleTest/UILogin";
        //string scenePath = "Scenes/Lobby";
        string scenePath = "Scenes/BattleMaps/tushancun_b01";
        StartCoroutine(LoadSceneFromAbAsync(scenePath));
        //StartCoroutine(ActgiveScene());
    }

    private LoadAsyncOperation request; 

    //异步场景加载测试
    //注意物体本身的释放
    IEnumerator LoadSceneFromAbAsync(string scenePath)
    {
        float b = Time.realtimeSinceStartup;
        request = ResourceService.Instance.LoadSceneAysnc(scenePath);
        if (request == null)
        {
            yield break;
        }

        // 测试参数设置
        //request.allowSceneActivation = true;
        //Debug.Log("LoadSceneAsync Test allowSceneActivation: false" );

        //测试进度信息获取
        //while (!request.isDone)
        //{
        //    Debug.Log("LoadSceneAsync Test process :" + request.progress);
        //    yield return null;
        //}

        //优先级
        //Debug.Log("LoadSceneAsync Test process :" + request.progress + ", Done :" + request.isDone);
        //Debug.Log("LoadSceneAsync Test priority :" + request.priority + ", Done :" + request.isDone);

        yield return (request);
        float e = Time.realtimeSinceStartup;

        Debug.Log("LoadSceneFromAbAsync Test process : " + scenePath + " Completed , Time:" + (e- b));

        TXT.text = (e - b).ToString();
    }

    IEnumerator ActgiveScene()
    {
        yield return new WaitForSeconds(0.5f);
        request.allowSceneActivation = true;
        Debug.Log("LoadSceneAsync Test allowSceneActivation: true");
    }

    private float callbackStartTime = 0;
    private void LoadWithCallBack()
    {
        callbackStartTime = Time.realtimeSinceStartup;
        string scenePath = "Scenes/Lobby";
        ResourceService.Instance.LoadSceneAysncWithCallback(scenePath, LoadSceneMode.Single, callback);
    }

    void callback(string str)
    {
        float e = Time.realtimeSinceStartup;
        TXT.text = (e - callbackStartTime).ToString();
        Debug.Log("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~LoadWithCallBack Test process Completed , Time:" + (e - callbackStartTime));
    }


    public void LoadLobbyFromResAsync()
    {
        StartCoroutine(LoadLobbyFromResourcesAsync());
    }

    private IEnumerator LoadLobbyFromResourcesAsync()
    {
        float b = Time.realtimeSinceStartup;
        AsyncOperation loadOperation = SceneMgr.LoadSceneAsync("Lobby", LoadSceneMode.Single);
        yield return loadOperation;
        float e = Time.realtimeSinceStartup;

        TXT.text = (e - b).ToString();

        Debug.Log("LoadLobbyFromResourcesAsync Test process Completed , Time:" + (e - b));
    }



    public void LoadLobbyFromAb()
    {
        syncStartTime = Time.realtimeSinceStartup;
        string scenePath = "Scenes/Lobby";
        //SceneManager.sceneLoaded += UnloadSceneAssetBundle;
        //ResourceService.Instance.LoadScene(scenePath, false);

        LoadWithCallBack();

        Debug.Log("LoadLobbyFromAb Test process Completed");
    }

    private float syncStartTime = 0;
    public void LoadLobbyFromRes()
    {
        syncStartTime = Time.realtimeSinceStartup;
        SceneManager.sceneLoaded += UnloadSceneAssetBundle;
        SceneMgr.LoadScene("Lobby", LoadSceneMode.Single);
        Debug.Log("LoadLobbyFromRes Test process Completed");
    }

    private void UnloadSceneAssetBundle(Scene scene, LoadSceneMode mode)
    {
        float e = Time.realtimeSinceStartup;
        TXT.text = (e - syncStartTime).ToString();
        Debug.Log("UnloadSceneAssetBundle Test process : " + scene.name + " Completed , Time:" + (e - syncStartTime));
        SceneManager.sceneLoaded -= UnloadSceneAssetBundle;
    }

    public void OnReturn()
    {
        Destroy(gameObject);
        Destroy(Canvas.gameObject);
        Destroy(Canvas.worldCamera.gameObject);

        SceneMgr.LoadScene("SceneChange");
    }


    public void GC()
    {
        ResourceService.Instance.UnloadAllAssetBundle();
        ResourceService.Instance.GC();
    }

    void OnDestroy()
    {
        Debug.Log("______________________________________SceneTest Release");
    }

}
