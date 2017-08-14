using System;
using System.Collections;
using UnityEngine;
using Object = UnityEngine.Object;
using AssetBundles ;
using Celf;
using UnityEngine.SceneManagement;


/// <summary>
/// 资源加载接口
/// NOTE:
/// ---1. 加载接口明确： 
/// -------* 受UseAssetBundle影响的接口, 建议明确使用提供的接口,如Character\Panel等在移动端通过AssetBundle加载的资源
/// -------* 不受UseAssetBundle影响的资源加载 ，请使用 “通用接口” 类型，明确区分资源来源和接口方式
/// ---2. 文件路径
/// ------* resourcesPath特指 "resources/" 文件夹下相对路径，如"ui/panel/testpanel"
/// ------* assetPath    特指 "Assets/" 文件夹下相对路径，如"resources/ui/panel/testpanel"
/// ---3. AssetBundleLoadOperation接口
/// ------* 
/// </summary>
public class ResourceService : Celf.Singleton<ResourceService>
{
    /// <summary>
    /// 是否从AssetBundle中加载资源
    /// </summary>
    public bool UseAssetBundle = true;

    public void Initialize()
    {
#if UsingAssetBundle
        UseAssetBundle = true ;
#endif
        //UseAssetBundle = false; //!Core.Platform.Instance.isEditor;

        Debug.LogWarning(UseAssetBundle?"ResourceService Load Mode：AssetBundle": "ResourceService Load Mode：Resources");

        if (UseAssetBundle)
        {
            AssetBundleManager.Instance.Initialize();
        }

        LoadSceneBuildSettings.Instance.Init();
    }

    protected override void OnRelease()
    {
        //StopAllCoroutines();
        UnloadUnusedAssets();
    }

#region AssetBundle Resources Interface (可能会 从AssetBundle进行加载,受UseAssetBundle设置影响)

    /// <summary>
    /// 同步加载 , 受ResourceService.UseAssetBundle 参数影响数据来源
    /// </summary>
    /// <typeparam name="T">类型</typeparam>
    /// <param name="resourcesPath"> "resources/"文件夹下路径 </param>
    /// <returns></returns>
    public T Load<T>(string resourcesPath) where T : UnityEngine.Object
    {
        if (string.IsNullOrEmpty(resourcesPath))
        {
            Debug.LogError("ResourceService.Load Error:resourcesPath" + resourcesPath + " is empty ");
            return null;
        }

        //Debug.Log("### ResourceService.Load path:" + resourcesPath);

        return UseAssetBundle ? LoadFromBundle<T>(resourcesPath) : LoadFromResources<T>(resourcesPath);
    }

    /// <summary>
    /// 异步加载, 受ResourceService.UseAssetBundle 参数影响数据来源
    /// </summary>
    /// <typeparam name="T">类型</typeparam>
    /// <param name="resourcesPath">"resources/"文件夹下路径</param>
    /// <returns></returns>
    public LoadAssetRequest LoadAsync<T>(string resourcesPath) where T : UnityEngine.Object
    {
        if (string.IsNullOrEmpty(resourcesPath))
        {
            Debug.LogError("ResourceService.LoadAsync Error:resourcesPath" + resourcesPath + " is empty ");
            return null;
        }

        Debug.Log("### ResourceService.LoadAssetAsync path:" + resourcesPath);

        if (UseAssetBundle)
        {
            return LoadFromBundleAsync<T>(resourcesPath);
        }
        else
        {
            ResourceRequest request = LoadFromResourcesAsync<T>(resourcesPath);
            if (request != null)
            {
                return new LoadAssetFromResourceRequest(request);
            }
            return null;
        }
    }

    /// <summary>
    /// 同步加载, 受ResourceService.UseAssetBundle 参数影响数据来源
    /// </summary>
    public GameObject LoadGameObject(string resourcesPath)
    {
        return Load<GameObject>(resourcesPath);
    }
    
    /// <summary>
    /// 异步加载
    /// </summary>
    public LoadAssetRequest LoadGameObjectAsync(string resourcesPath)
    {
        return LoadAsync<GameObject>(resourcesPath);
    }

    public GameObject LoadCharacter(string resourcesPath)
    {
        return Load<GameObject>(resourcesPath);
    }

    public LoadAssetRequest LoadCharacterAsync(string resourcesPath)
    {
        return LoadAsync<GameObject>(resourcesPath);
    }

    public LoadAssetRequest LoadPanelAsync(string resourcesPath)
    {
        return LoadAsync<GameObject>(resourcesPath);
    }

    public GameObject LoadPanel(string resourcesPath)
    {
        return Load<GameObject>(resourcesPath);
    }

    public Sprite LoadIcon(string resourcesPath)
    {
        return Load<Sprite>(resourcesPath);
    }

    public LoadAssetRequest LoadIconAsync(string resourcesPath)
    {
        return LoadAsync<Sprite>(resourcesPath);
    }

    public GameObject LoadCamera(string resourcesPath)
    {
        return Load<GameObject>(resourcesPath);
    }

    public LoadAssetRequest LoadCameraAsync(string resourcesPath)
    {
        return LoadAsync<GameObject>(resourcesPath);
    }

    public GameObject LoadCinematic(string resourcesPath)
    {
        return Load<GameObject>(resourcesPath);
    }

    public LoadAssetRequest LoadCinematicAsync(string resourcesPath)
    {
        return LoadAsync<GameObject>(resourcesPath);
    }

    public GameObject LoadStage(string resourcesPath)
    {
        return Load<GameObject>(resourcesPath);
    }

    public LoadAssetRequest LoadStageAsync(string resourcesPath)
    {
        return LoadAsync<GameObject>(resourcesPath);
    }

    //--------------------------------------------------------------------------------------------

    public void LoadSceneByName(string sceneName, LoadSceneMode mode = LoadSceneMode.Single)
    {
        string scenePath = LoadSceneBuildSettings.Instance.GetScenePath(sceneName);
        if (string.IsNullOrEmpty(scenePath))
        {
            Debug.LogError("LoadSceneByName Error: Cannot find ScenePath from " + sceneName);
            return;
        }

        LoadScene(scenePath, mode);
    }

    public LoadAsyncOperation LoadSceneByNameAsync(string sceneName, LoadSceneMode mode = LoadSceneMode.Single)
    {
        string scenePath = LoadSceneBuildSettings.Instance.GetScenePath(sceneName);
        if (string.IsNullOrEmpty(scenePath))
        {
            Debug.LogError("LoadSceneByNameAsync Error: Cannot find ScenePath from " + sceneName);
            return null;
        }
        return LoadSceneAysnc(scenePath, mode);
    }

    /// <summary>
    /// 同步加载场景资源,受ResourceService.UseAssetBundle 参数影响数据来源。 明确进行打包的场景使用该接口
    /// </summary>
    /// <param name="assetPath"> "Assets/" 下相对路径 </param>
    /// <param name="isAdditive">是否叠加在当前场景</param>
    /// 
    public void LoadScene(string assetPath, LoadSceneMode mode = LoadSceneMode.Single)
    {
        if (string.IsNullOrEmpty(assetPath))
        {
            Debug.LogError("ResourceService.LoadScene Error:assetPath is empty ");
            return;
        }

        //Debug.Log("__________________________________ResourceServece. LoadScene :" + assetPath);

        if (!UseAssetBundle)
        {
            string sceneName = assetPath.Substring(assetPath.LastIndexOf("/") + 1);
            SceneMgr.LoadScene(sceneName, mode);
            return;
        }

        AssetBundle bundle = AssetBundleManager.Instance.GetAssetBundle(assetPath);
        if (bundle == null || bundle.isStreamedSceneAssetBundle == false)
        {
            Debug.LogError("LoadScene Error: miss resourcer, path:" + assetPath);
            return;
        }

        string[] scenePath = bundle.GetAllScenePaths();
        WaitUnloadSceneAssetBundle(scenePath[0]);

        SceneMgr.LoadScene(scenePath[0], mode);
    }

    private string mTempLoadScenePath = "";
    /// <summary>
    /// 等待加载结束再卸载场景AssetBundle资源，不然会有很大概率出现资源缺失
    /// </summary>
    /// TODO NOTE: 同一时刻只能处理一个场景资源卸载，如果需要同时加载多个场景需要处理
    private void WaitUnloadSceneAssetBundle(string loadingScenePath)
    {
        if (string.IsNullOrEmpty(loadingScenePath))
        {
            return;
        }

        mTempLoadScenePath = loadingScenePath;
        SceneManager.sceneLoaded += UnloadSceneAssetBundle;
    }

    private void UnloadSceneAssetBundle(Scene scene, LoadSceneMode mode)
    {
        if (!string.IsNullOrEmpty(mTempLoadScenePath))
        {
            AssetBundleManager.Instance.UnloadAssetBundleByPath(mTempLoadScenePath);
            mTempLoadScenePath = "";
            SceneManager.sceneLoaded -= UnloadSceneAssetBundle;
        }
    }

    /// <summary>
    /// 异步加载场景资源,受ResourceService.UseAssetBundle 参数影响数据来源。 明确进行打包的场景使用该接口
    /// </summary>
    /// <param name="assetPath"> "Assets/" 下相对路径 </param>
    /// <param name="isAdditive">是否叠加在当前场景</param>
    public LoadAsyncOperation LoadSceneAysnc(string assetPath, LoadSceneMode mode = LoadSceneMode.Single)
    {
        if (string.IsNullOrEmpty(assetPath))
        {
            Debug.LogError("ResourceService.LoadSceneAysnc Error:assetPath is empty ");
            return null;
        }
        
        //Debug.Log("__________________________________ResourceServece. LoadSceneAysnc :" + assetPath);
        
        if (UseAssetBundle)
        {
            LoadAsyncOperation option = AssetBundleManager.Instance.LoadSceneAsync(assetPath, mode == LoadSceneMode.Additive);
            StartCoroutine(WaitUnloadSceneBundleWhenCompletedAsync(option, assetPath));
            return option;
        }
        else
        {
            string sceneName = assetPath.Substring(assetPath.LastIndexOf("/") + 1);
            AsyncOperation option= SceneMgr.LoadSceneAsync(sceneName, mode);
            return new AsyncOperationAdapter(option);
        }
    }
    
    [Obsolete("建议使用协程方式处理异步")]
    public void LoadSceneAysncWithCallback(string assetPath, LoadSceneMode mode = LoadSceneMode.Single, Action<string> callback = null)
    {
        if (string.IsNullOrEmpty(assetPath))
        {
            Debug.LogError("LoadSceneAysnc Error: projectPath is empty");
            return;
        }

        if (!UseAssetBundle)
        {
            string sceneName = assetPath.Substring(assetPath.LastIndexOf("/") + 1);
            AsyncOperation option =  SceneMgr.LoadSceneAsync(sceneName, mode);
            StartCoroutine(WaitUnloadSceneBundleWhenCompletedAsync(new AsyncOperationAdapter(option), assetPath, callback));
            return;
        }

        StartCoroutine(AssetBundleManager.Instance.GetAssetBundleAsyncWithCallBack(assetPath, bundle =>
        {
            if (bundle == null)
            {
                Debug.LogError("LoadSceneAyncInternal Error: miss resourcer, path:" + assetPath);
            }
            else
            {
                if (bundle.isStreamedSceneAssetBundle == false)
                {
                    Debug.LogError(
                        "LoadSceneAyncInternal Error: AssetBundle is not StreamedScene AssetBundle, Path:" +
                        assetPath);
                }
                else
                {
                    string[] scenePaths = bundle.GetAllScenePaths();
                    AsyncOperation option = SceneManager.LoadSceneAsync(scenePaths[0], mode);
                    StartCoroutine(WaitUnloadSceneBundleWhenCompletedAsync(new AsyncOperationAdapter(option), assetPath, callback));
                }
            }
        }
        ));
    }

    private IEnumerator WaitUnloadSceneBundleWhenCompletedAsync(LoadAsyncOperation option, string assetPath, Action<string> callBack = null)
    {
        yield return option;
        if (callBack != null)
        {
            callBack(assetPath);
        }
        yield return new WaitForSeconds(1.0f);
        AssetBundleManager.Instance.UnloadAssetBundleByPath(assetPath);
    }
    //---------------------------------------------------------------------------------------------------------------
    /// <summary>
    /// 加载Atlas
    /// NOTE: 非Asstbundle模式下需要在resources下生成引用关系 (AtlasPacker)
    /// </summary>
    /// <param name="assetPath">  "ui/atlas/login" , "ui/atlas/battle" , "ui/atlas/main" , "ui/atlas/common"</param>
    public UIAtlas LoadAtals(string assetPath)
    {
        UIAtlas uiAtlas = null;

        if (string.IsNullOrEmpty(assetPath))
        {
            return uiAtlas;
        }

        if (UseAssetBundle)
        {
            AssetBundle bundle = AssetBundleManager.Instance.GetAssetBundle(assetPath);
            if (bundle == null)
            {
                Debug.LogError("ResouceService.LoadAtlas Load Fail");
                return null;
            }

            Sprite[] sprites = bundle.LoadAllAssets<Sprite>();
            UIAtlas atlas = new UIAtlas();
            for (int i = 0; i < sprites.Length; ++i)
            {
                atlas.AddSprite(sprites[i]);
            }
        }
        else
        {
            assetPath = assetPath.ToLower();
            assetPath = "atlas/"  + assetPath.Replace('/', '_');
            uiAtlas = Resources.Load<UIAtlas>(assetPath);
        }
        return uiAtlas;
    }
    
    /// <summary>
    /// 强制删除Atlas Bundle资源
    /// </summary>
    /// <param name="assetPath">  "ui/atlas/login" , "ui/atlas/battle" , "ui/atlas/main" , "ui/atlas/common"</param>
    public void UnloadAtlas(string assetPath)
    {
        if (UseAssetBundle)
        {
            AssetBundleManager.Instance.ForceUnloadAssetBundle(assetPath);
        }
        else
        {
            
        }
    }
#endregion

#region Common Interface
    /// <summary>
    /// 同步从AssetBundle中加载
    /// </summary>
    private T LoadFromBundle<T>(string resourcePath) where T : UnityEngine.Object
    {
        T obj = AssetBundleManager.Instance.LoadAsset<T>("Resources/" + resourcePath,false);
        return obj;
    }

    /// <summary>
    /// 异步从AssetBundle中加载
    /// </summary>
    private LoadAssetRequest LoadFromBundleAsync<T>(string resourcePath) where T : UnityEngine.Object
    {
        return AssetBundleManager.Instance.LoadAssetAsync<T>("Resources/" + resourcePath, false);
    }

    /// <summary>
    /// 异步从Resource中加载
    /// </summary>
    public ResourceRequest LoadFromResourcesAsync<T>(string resourcePath) where T : UnityEngine.Object
    {
        return Resources.LoadAsync<T>(resourcePath);
    }

    /// <summary>
    /// 同步从Resource中加载
    /// </summary>
    public T LoadFromResources<T>(string resourcePath) where T : UnityEngine.Object
    {
        try
        {
            T go = Resources.Load<T>(resourcePath);
            return go;
        }
        catch (Exception ex)
        {
            Debug.LogError("ResourceService.LoadFromResources<T> Error:" + ex.ToString());
        }
        return null;
    }

    public void UnloadFromResources(UnityEngine.Object obj)
    {
        Resources.UnloadAsset(obj);
    }

    /// <summary>
    /// 强制AssetBundle卸载资源（不包含静态资源类型以及该资源的依赖资源）, 不考虑当前引用情况
    /// </summary>
    public void UnloadAllBundles(string assetPath)
    {
        AssetBundleManager.Instance.ForceUnloadAssetBundle(assetPath);
    }

    /// <summary>
    /// 卸载所有AssetBundle资源，（不包含静态资源和需要手动卸载的资源）
    /// </summary>
    public void UnloadAllAssetBundle()
    {
        AssetBundleManager.Instance.UnloadAllAssetBundle();
    }

    public void UnloadUnusedAssets()
    {
        Resources.UnloadUnusedAssets();
    }

    public T SafeConvertObject<T>(UnityEngine.Object obj) where T : UnityEngine.Object
    {
        T t = null;
        if (obj != null)
        {
            t = obj as T;
            if (t == null)
            {
                UnityEngine.Object.Destroy(obj);
                Debug.LogError("SafeConvertObject<T>(), type convert fail.");
            }
        }
        return t;
    }

#endregion

#region 其他接口
    public Coroutine LoadUrlTextureAsynch(string url, System.Action<Texture2D> eventHandler = null)
    {
        return StartCoroutine(LoadUrlTextureAsynchCoroutine(url, eventHandler));
    }

    public IEnumerator LoadUrlTextureAsynchCoroutine(string url, System.Action<Texture2D> eventHandler)
    {
        Texture2D tex = null;

        WWW www = new WWW(url);
        yield return www;
        using (www)
        {
            if (!www.isDone)
            {
                Debug.LogError("www.isDone error:" + url);
            }
            else if (!string.IsNullOrEmpty(www.error))
            {
                Debug.LogError("www.error:" + www.error);
            }

            tex = www.texture;

            //todo 是否要释放
            //
            //www.Dispose();
            //www = null;
        }

        eventHandler(tex);
    }
#endregion

#region  Memory Management

    private System.Action mLowMemoryHandler;
    private bool mCleaningMemory = false;

    public void ListenOnLowMemory(System.Action handler)
    {
        mLowMemoryHandler += handler;
    }

    public void UnlistenOnLowMemory(System.Action handler)
    {
        mLowMemoryHandler -= handler;
    }

    public void GC()
    {
        //ReportService.ReportEvent("ResourceService.GC", true);

        if (!mCleaningMemory)
        {
            mCleaningMemory = true;

            if (mLowMemoryHandler != null)
            {
                System.Delegate[] delegates = mLowMemoryHandler.GetInvocationList();
                foreach (System.Action action in delegates)
                {
                    action();
                }
            }

            StartCoroutine(GCCoroutine());
        }
    }

    private IEnumerator GCCoroutine()
    {
        System.GC.Collect();
        yield return null;
        UnloadUnusedAssets();
        mCleaningMemory = false;
    }

#endregion
}