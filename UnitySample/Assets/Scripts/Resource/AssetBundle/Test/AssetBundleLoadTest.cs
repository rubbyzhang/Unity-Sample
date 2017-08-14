using System.Collections;
using System.Collections.Generic;
using System.ComponentModel.Design;
//using Celf.Camx;
using UnityEngine;
using  Celf ;
//using Celf.UI;
using UnityEngine.SceneManagement;
using UnityEngine.UI ;
using AssetBundles;
//using ZXing;

public class AssetBundleLoadTest : MonoBehaviour
{
    //UI Test
    public string PanelName = "";
    public Image TestIamge1;
    public Image TestIamge2;
    public Transform uiRoot;


    void Awake()
    {
        AssetBundleManager.Instance.Initialize();
    }
    void Start()
    {
        // UILoadTest();

        //TestEffect();
        //TestScene();
        //TestCamera();
        //CharacterTest();
        string AssetPath = "Resources/prefabs/Story/StoryManager";
        LoadAsset(AssetPath);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.P))
        {
            AssetBundleManager.Instance.PrintAllLoadedAssetBundleName();
        }
    }

    public void UIAtlasTest_ChangeScene()
    {
        //SceneManager.LoadScene("SceneChange");
        //LoadScene("Scenes/AssetBundleTest/SceneChange");
        
        //切换场景
        ResourceService.Instance.LoadSceneAysnc("Scenes/AssetBundleTest/SceneChange");

        //强制释放Atlas资源
        AssetBundleManager.Instance.ForceUnloadAssetBundle("ui/atlas/login");
        AssetBundleManager.Instance.ForceUnloadAssetBundle("ui/atlas/battle");
    }

    //void UILoadTest()
    //{
    //    if (string.IsNullOrEmpty(PanelName))
    //    {
    //        return;
    //    }

    //    //panel
    //    StartCoroutine(LoadPanelAsync("ui/panel/" + PanelName));
    //    //sync icon
    //    //LoadDynamicImage("ui/icon/daimao01");
    //    //async icon
    //    //StartCoroutine(LoadDynamicImageAysc("ui/icon/daimao02"));

    //    if (PanelName == "Test_Battle_Panel")
    //    {
    //        //load atlas sprite
    //        string spritePath = "atlas/battle/jineng_k_zhudong";
    //        DynamicImage dynamicImage = TestIamge2.gameObject.AddComponent<DynamicImage>();
    //        dynamicImage.SetAtlasPath(spritePath);

    //        spritePath = "atlas/battle/jineng_k_zhudong";
    //        DynamicImage dynamicImage2 = TestIamge1.gameObject.AddComponent<DynamicImage>();
    //        dynamicImage2.SetAtlasPath(spritePath);
    //    }
    //    else
    //    {
    //        //load atlas sprite
    //        string spritePath = "atlas/login/login_btn";
    //        DynamicImage dynamicImage = TestIamge2.gameObject.AddComponent<DynamicImage>();
    //        dynamicImage.SetAtlasPath(spritePath);

    //        spritePath = "atlas/login/select_btn";
    //        DynamicImage dynamicImage2 = TestIamge1.gameObject.AddComponent<DynamicImage>();
    //        dynamicImage2.SetAtlasPath(spritePath);
    //    }
    //}

    //private void LoadSprite(string spritePath)
    //{
    //    //AssetBundle bundle = AssetBundleManager.Instance.GetAssetBundle(atlasPath);
    //    //Sprite sprite = bundle.LoadAsset<Sprite>("battle_btn_word1");
    //    //TestIamge2.sprite = sprite;

    //    DynamicImage dynamicImage = TestIamge2.gameObject.AddComponent<DynamicImage>();
    //    dynamicImage.SetPath(spritePath);
    //}

    private IEnumerator LoadPanelAsync(string name)
    {
        var request = ResourceService.Instance.LoadPanelAsync(name);
        yield return request;
        GameObject panel = Instantiate(request.asset as GameObject, uiRoot);
        panel.SetActive(true);
    }

    //加载图片
    private void LoadDynamicImage(string atlasName)
    {
        Sprite image = ResourceService.Instance.LoadIcon(atlasName);
        TestIamge1.sprite = image;
    }

    //异步加载图片
    private IEnumerator LoadDynamicImageAysc(string atlasName)
    {
        //var option = AssetBundleManager.Instance.LoadAssetAsync<Sprite>("Resources/" + atlasName);

        var option = ResourceService.Instance.LoadIconAsync(atlasName);

        while (!option.isDone)
        {
            yield return null;
        }

        yield return option;

        Sprite image = option.asset as Sprite;
        TestIamge2.sprite = image;
    }

    void CharacterTest()
    {
        string AssetPath = "Resources/character/kp_tushansusu01/system_kp_tushansusu01";
        LoadAsset(AssetPath);
        LoadAssetAsync(AssetPath);
    }
    void TestCamera()
    {
        //CamxService.Instance.LoadCamera("scene/camera/camera_6v6");
    }

    private void TestEffect()
    {
        LoadAsset("Resources/effect/susu_attack01_smoke");
    }

    private void TestScene()
    {
        //string bundleName = "scene_sceneb.unity3d";
        //string scenename = "SceneB";

        string bundleName = "Scenes/AssetBundleTest/SceneChange";
        StartCoroutine(LoadSceneAync(bundleName));
    }

    void LoadScene(string bundleName)
    {
        AssetBundle bundle = AssetBundleManager.Instance.GetAssetBundle(bundleName);

        if (bundle.isStreamedSceneAssetBundle)
        {
            string[] scenPath = bundle.GetAllScenePaths();
            SceneManager.LoadScene(scenPath[0], LoadSceneMode.Single);
        }
    }

    //场景异步加载测试
    IEnumerator LoadSceneAync(string bundleName)
    {
        var request = ResourceService.Instance.LoadSceneAysnc(bundleName,LoadSceneMode.Additive);
        yield return request;
        Debug.Log("_______________________LoadSceneAync over" );
    }

    /// 同步加载资源
    private void LoadAsset(string loadName, bool unloadDependencies = true)
    {
        GameObject obj = AssetBundleManager.Instance.LoadAsset<GameObject>(loadName, unloadDependencies);

        GameObject obj2 = Instantiate(obj);
        obj2.name = obj2.name + "__sync";
        obj2.SetActive(true);
        obj2.transform.localPosition = new Vector3(-0.65f, 0, -9);
    }

    // 异步回调方式加载资源
    private void LoadAssetAsync(string loadName)
    {
        AssetBundleManager.Instance.LoadAssetAsyncWithCallback<GameObject>(loadName, CallBack);
    }

    void CallBack(GameObject obj)
    {
        if (obj != null)
        {
            GameObject obj2 = Instantiate(obj);
            obj2.name = obj2.name + "__async";
            obj2.transform.localPosition = new Vector3(0.3f, 0, -10);
            obj2.SetActive(true);
        }
    }
}
