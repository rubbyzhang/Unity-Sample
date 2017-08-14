using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Collections;
//using PixelCrushers.DialogueSystem;
using AssetBundleManager = AssetBundles.AssetBundleManager;
using Toggle = UnityEngine.UI.Toggle;

public class CharacterLoadTest : MonoBehaviour
{
    public Text TimeText;
    public Toggle Toggle;
    public Toggle Toggle2;

    private string[] mAssetPath =
    {
        "character/kp_tushansusu01/system_kp_tushansusu01" ,
        "character/kp_tushanyaya01/fighting_kp_tushanyaya01" ,

        "character/kp_tushansusu01/system_kp_tushansusu01" ,

        "character/kp_tushanyaya01/fighting_kp_tushanyaya01" ,
        "character/kp_wangquanfugui01/fighting_kp_wangquanfugui01",
    };

    private List<GameObject> mChatacter = new List<GameObject>();
    private bool isAysnc = false;
    private bool isResources = false;
    private bool IsUnloadDependencies = true;

    private bool UsingCache = false;
    private  Dictionary<string, GameObject> mChache = new Dictionary<string, GameObject>();


    //private void PreCache()
    //{
    //    for (int i = 0; i < mAssetPath.Length; ++ i)
    //    {
    //        GameObject obj = AssetBundleManager.Instance.LoadObjectFromAssetBundle<GameObject>(mAssetPath[i]);
    //        mChache.Add(mAssetPath[i], obj);
    //    }
    //}

    void Awake()
    {
        //PreCache();

        Load(mAssetPath[0]);

        if (Toggle != null)
        {
            Toggle.onValueChanged.AddListener(CheckToogle);
        }

        if (Toggle2 != null)
        {
            Toggle2.onValueChanged.AddListener(CheckToogle2);
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.P))
        {
            AssetBundleManager.Instance.PrintAllLoadedAssetBundleName();
        }
    }

public void CheckToogle(bool isACtive)
    {
        isAysnc = !isACtive;
        Debug.Log("aYSNC CheckToogle:" + isAysnc);
    }

    public void CheckToogle2(bool isACtive)
    {
        IsUnloadDependencies = !IsUnloadDependencies;
        Debug.Log("IsUnloadDependencies CheckToogle:" + IsUnloadDependencies);
    }

    public  void wangquan()
    {
        //Load(mAssetPath[4]);

        for (int i = 0; i < 2; i ++)
        {
            Load(mAssetPath[i]);
        }
    }

    public void sususysytem()
    {
        Load(mAssetPath[0]);
    }

    public void susufight()
    {
        Load(mAssetPath[1]);
    }

    public void yayasysytem()
    {
        Load(mAssetPath[2]);
    }

    public void yayafight()
    {
        Load(mAssetPath[3]);
    }

    public void DestroyCharacter2()
    {
        if (mChatacter != null)
        {
            for (int i = 0; i < mChatacter.Count; i++)
            {
             DestroyCharacter(mChatacter[i]);

            }
        }
        ResourceService.Instance.GC();
    }

    public void GCtEST()
    {
        AssetBundleManager.Instance.UnloadAllAssetBundle();
        ResourceService.Instance.GC();
    }

    private double time_b = 0;
    private double time_e = 0;
    private double time_m = 0;
    private void Load(string assetPath)
    {
        Debug.Log("__________________Load:" + assetPath);

        //if (mChache.ContainsKey(assetPath))
        //{
        //    time_b = Time.realtimeSinceStartup;
        //    GameObject obj = mChache[assetPath];
        //    time_m = Time.realtimeSinceStartup;

        //    if (obj != null)
        //    {
        //        InstantiateCharacter(obj);
        //    }

        //    return;
        //}

        if (isAysnc)
        {
            StartCoroutine(LoadAssetAync(assetPath));
            //LoadAssetAyncWithCallBack(assetPath);
        }
        else
        {
            LoadAsset(assetPath);
        }
    }

    private void LoadAsset(string loadName)
    {
        Debug.Log("----------------------------------------------角色同步加载测试 LoadAssetAync ");

        time_b = Time.realtimeSinceStartup;
        GameObject obj = null;
        if (isResources)
        {
            Debug.Log("__________________Resources LoadAsset");
            obj = Resources.Load<GameObject>(loadName);
        }
        else
        {
            Debug.Log("__________________AssetBundle LoadAsset");
            obj = AssetBundleManager.Instance.LoadAsset<GameObject>("Resources/" + loadName);
        }

        time_m = Time.realtimeSinceStartup;

        if (obj != null)
        {
            InstantiateCharacter(obj);
        }
    }

    IEnumerator LoadAssetAync(string loadName)
    {
        Debug.Log("----------------------------------------------角色异步加载测试 LoadAssetAync ");
        time_b = Time.realtimeSinceStartup;

        var request = AssetBundleManager.Instance.LoadAssetAsync<GameObject>("Resources/" + loadName, IsUnloadDependencies);
        yield return StartCoroutine(request);

        time_m = Time.realtimeSinceStartup;

        GameObject obj = request.asset as GameObject;

        if (obj != null)
        {
            InstantiateCharacter(obj);
        }
    }

    void LoadAssetAyncWithCallBack(string loadName)
    {
        Debug.Log("__________________######LoadAssetAync");

        time_b = Time.realtimeSinceStartup;
        AssetBundleManager.Instance.LoadAssetAsyncWithCallback<GameObject>("Resources/" + loadName, CallBack );
    }

    void CallBack(GameObject obj)
    {
        time_m = Time.realtimeSinceStartup;

        if (obj != null)
        {
            InstantiateCharacter(obj);
        }
    }

    void InstantiateCharacter(GameObject obj)
    {
        GameObject  mGameObject = Instantiate(obj);
        time_e = Time.realtimeSinceStartup;

        TimeText.text = string.Format("Load: {0:0.000} , Ins: {1:0.000}", (time_m - time_b) , (time_e - time_m));
        mGameObject.name = "1";
        mGameObject.SetActive(true);
        mGameObject.transform.localEulerAngles = new Vector3(0, 180, 0);
        mGameObject.transform.localPosition = new Vector3(Random.Range(-1,1), Random.Range(-1, 1), 3.65f);

        mChatacter.Add(mGameObject);
    }

    void DestroyCharacter(GameObject charac)
    {
       Destroy(charac);
    }
}
