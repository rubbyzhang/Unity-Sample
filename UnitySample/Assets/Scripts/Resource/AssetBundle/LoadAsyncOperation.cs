using System;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections;
using AssetBundles;
using Object = UnityEngine.Object;

/// <summary>
/// 等待资源加载结束，用于协程
/// </summary>
public abstract class WaitForLoadComplete : CustomYieldInstruction
{
    public override bool keepWaiting
    {
        get { return !IsCompleted(); }
    }

    public abstract bool IsCompleted();

    /// <summary>
    /// 外部Update中进行更新
    /// </summary>
    /// <returns>返回False 则停止后续更新</returns>
    public abstract bool UpdateState();
}

/// <summary>
/// 等待下载资源结束
/// </summary>
public abstract class LoadBundleOperation : WaitForLoadComplete
{
    bool done;

    public string assetBundleName { get; private set; }
    public LoadedAssetBundle assetBundle { get; protected set; }
    public string error { get; protected set; }

    protected abstract bool downloadIsDone { get; }
    protected abstract void FinishDownload();

    ~LoadBundleOperation()
    {
        //Debug.Log("~~~~ LoadAssetBundleOperation析构");           
    }
    public override bool UpdateState()
    {
        if (!done && downloadIsDone)
        {
            FinishDownload();
            done = true;
        }
        return !done;
    }

    public override bool IsCompleted()
    {
        return done;
    }

    public AsyncTimeMonitor TimeMonitor { get; set; }

    public LoadBundleOperation(string assetBundleName)
    {
        this.assetBundleName = assetBundleName;
        TimeMonitor = new AsyncTimeMonitor();
    }
}

/// <summary>
/// 等待资源从文件中加载结束
/// </summary>
public class LoadBundleFromFileOperation : LoadBundleOperation
{
    private AssetBundleCreateRequest m_Request;

    public LoadBundleFromFileOperation(string assetBundleName, AssetBundleCreateRequest request) : base(assetBundleName)
    {
        m_Request = request;
    }

    protected override bool downloadIsDone
    {
        get { return m_Request == null || m_Request.isDone; } 
    }

    protected override void FinishDownload()
    {
        if (m_Request == null)
        {
            return;
        }

        AssetBundle bundle = m_Request.assetBundle;
        //Debug.Log("TimeMonitor _________________________________LoadBundleFromFileOperation Time(" + assetBundleName + ") :" + TimeMonitor.Duration);

        if (bundle == null)
        {
            error = string.Format("{0} is not a valid asset bundle From File .", assetBundleName);
        }
        else
        {
            assetBundle = new LoadedAssetBundle(bundle);
        }
    }
}

/// <summary>
/// 等待资源从网络加载下载结束
/// </summary>
public class LoadBundleFromWebOperation : LoadBundleOperation
{
    WWW m_WWW;
    string m_Url;

    public LoadBundleFromWebOperation(string assetBundleName, WWW www)
        : base(assetBundleName)
    {
        if (www == null)
        {
            throw new System.ArgumentNullException("www");
        }

        m_Url = www.url;
        this.m_WWW = www;
    }

    protected override bool downloadIsDone { get { return (m_WWW == null) || m_WWW.isDone; } }

    protected override void FinishDownload()
    {
        error = m_WWW.error;
        if (!string.IsNullOrEmpty(error))
        {
            return;
        }

        AssetBundle bundle = m_WWW.assetBundle;
        if (bundle == null)
        {
            error = string.Format("{0} is not a valid asset bundle From web.", assetBundleName);
        }
        else
        {
            assetBundle = new LoadedAssetBundle(m_WWW.assetBundle);
        }
        //Debug.Log("TimeMonitor ________________________________LoadBundleFromWebOperation Time(" + assetBundleName + ") :" + TimeMonitor.Duration);

        m_WWW.Dispose();
        m_WWW = null;
    }
}

/// <summary>
/// 监测异步加载时长
/// </summary>
public class AsyncTimeMonitor
{
    public float StartTime;
    private float mTimeLine = AssetBundleConfig.ConstAsyncLoadAssetTimeLimit;

    public AsyncTimeMonitor()
    {
        StartTime = Time.realtimeSinceStartup;
    }

    public void SetTimeLine(float timeline)
    {
        mTimeLine = timeline;
    }

    public float Duration
    {
        get { return Time.realtimeSinceStartup - StartTime; }
    }

    public bool Timeout()
    {
        float diff = Time.realtimeSinceStartup - StartTime;
        return diff > mTimeLine;
    }

    public void Reset()
    {
        StartTime = Time.realtimeSinceStartup;
    }
}

/// <summary>
/// 异步加载申请
/// </summary>
public abstract class LoadAsyncOperation: WaitForLoadComplete
{
    public abstract override bool UpdateState();
    public abstract override bool IsCompleted();

    public AsyncTimeMonitor TimeMonitor { get; set; }

    protected LoadAsyncOperation()
    {
        TimeMonitor = new AsyncTimeMonitor();
    }

    protected void SetTimeLine(float timeLine = AssetBundleConfig.ConstAsyncLoadAssetTimeLimit)
    {
        TimeMonitor.SetTimeLine(timeLine);
    }


    private AsyncOperation mAsyncSetting;
    public AsyncOperation AsyncSetting
    {
        get { return mAsyncSetting; }
        protected set
        {
            if (value == null)
            {
                return;
            }

            mAsyncSetting = value ;

            mAsyncSetting.allowSceneActivation = allowSceneActivation_cache;
            mAsyncSetting.priority = priority_cache;
        }
    }

    public virtual bool isDone
    {
        get
        {
            return IsCompleted();
        }
    }

    public virtual float progress
    {
         get
        {
            if (AsyncSetting == null)
            {
                //异步流程中暂且不考虑AB加载时间
                return 0.0f;
            }

            return AsyncSetting.progress;
        }
    }

    //默认设置, 处理流程在加载AB过程中AsyncOperation没初始化时参数设置
    private bool allowSceneActivation_cache = true;  
    public virtual bool allowSceneActivation
    {
        get
        {
            if (AsyncSetting == null)
            {
                return true;
            }

            return AsyncSetting.allowSceneActivation;
        }

        set
        {
            if (AsyncSetting == null)
            {
                allowSceneActivation_cache = value;
                return;
            }

            AsyncSetting.allowSceneActivation = value;
        }
    }

    private int priority_cache = 0;
    public virtual int priority
    {
        get
        {
            if (AsyncSetting == null)
            {
                return 0;
            }

            return AsyncSetting.priority;
        }

        set
        {
            if (AsyncSetting == null)
            {
                priority_cache = value;
                return;
            }
            AsyncSetting.priority = value;
        }
    }
}

/// <summary>
/// 兼容 Unity AsyncOperation
/// </summary>
public class AsyncOperationAdapter : LoadAsyncOperation
{
    public AsyncOperationAdapter(AsyncOperation request)
    {
        AsyncSetting = request;
    }

    public override bool UpdateState()
    {
        return !IsCompleted();
    }

    public override bool IsCompleted()
    {
        return AsyncSetting == null || AsyncSetting.isDone;
    }
}

/// <summary>
/// 异步资源加载（从AsssetBundle或者Resources）
/// </summary>
public abstract class LoadAssetRequest : LoadAsyncOperation
{
    public abstract Object asset { get; }
}

/// <summary>
/// 等待AssetBundle(包含依赖) 以及 Asset 加载结束
/// </summary>
public class LoadAssetFromBundleRequest : LoadAssetRequest
{
    protected string mAssetBundleName;

    protected string mAssetName;

    protected System.Type mType;

    protected AssetBundleRequest mRequest = null;

    protected bool mUnloadDependencies = true;

    private bool mIsWaiting = true;

    public LoadAssetFromBundleRequest(string bundleName, string assetName, System.Type type, bool unloadDependencies = true)
    {
        mAssetBundleName = bundleName;
        mAssetName = assetName;
        mType = type;
        mUnloadDependencies = unloadDependencies;
    }

    ~ LoadAssetFromBundleRequest()
    {
        //Debug.Log("~~~~LoadAssetFromBundleRequest 析构");      
    }

    public override Object asset
    {
        get
        {
            if (mRequest != null && mRequest.isDone)
            {
                return mRequest.asset;
            }
            return null;
        }
    }
        
    public override bool UpdateState()
    {
        mIsWaiting = KeepWaiting();
        return mIsWaiting;
    }

    public override bool IsCompleted()
    {
        return !mIsWaiting;
    }

    private bool KeepWaiting()
    {
        if (string.IsNullOrEmpty(mAssetBundleName) || string.IsNullOrEmpty(mAssetName))
        {
            Debug.LogError("LoadAssetFromBundleRequest Error: input name is invalid");
            return false;
        }

        if (TimeMonitor != null && TimeMonitor.Timeout())
        {
            Debug.LogError("LoadAssetFromBundleRequest Error: Time Out , Bundle:" + mAssetBundleName);
            return false;
        }

        if (mRequest == null)
        {
            // do not care dependencies asset
            string loadError = AssetBundleManager.Instance.GetAsyncLoadError(mAssetBundleName);
            if (loadError != null)
            {
                return false;
            }

            //Debug.Log("LoadAssetFromBundleRequest 等待从文件异步加载资源结束  :" + mAssetBundleName);

            LoadedAssetBundle bundle = AssetBundleManager.Instance.GetLoadedAssetBundle(mAssetBundleName);
            if (bundle != null)
            {
                try
                {

                    mRequest = bundle.AssetBundle.LoadAssetAsync(mAssetName, mType);

                    AsyncSetting = mRequest;
                }
                catch (Exception e)
                {
                    Debug.LogError("LoadAssetFromBundleRequest Error in Load Bunddle:" + mAssetBundleName + ",ERROR:" + e.ToString());
                    return false;
                }
            }
        }
        else
        {
            if (mRequest.isDone)
            {
                AssetBundleUtil.ResetShaderInEditor(mRequest.asset as GameObject);

                //AssetBundleManager.Instance.UnloadAssetBundle(mAssetBundleName, mUnloadDependencies);

                Debug.Log("###TimeMonitor----------------------------LoadAssetFromBundleRequest 资源异步加载结束" + mAssetBundleName + "持续时时间:" + TimeMonitor.Duration);

                return false;
            }
        }

        return true;  //继续等待
    }
}

/// <summary>
/// ResourceRequest类型适配，不会走UpdateState更新流程结束,依赖isDone的监测来进行判断
/// </summary>
public class LoadAssetFromResourceRequest : LoadAssetRequest
{
    private ResourceRequest mRequest;

    public LoadAssetFromResourceRequest(ResourceRequest request)
    {
        mRequest = request;
        if (mRequest == null)
        {
            Debug.LogError("LoadAssetFromResourceRequest Error: input is invalid");
        }
    }

    ~LoadAssetFromResourceRequest()
    {
        //Debug.Log("~~~~LoadAssetFromResourceRequest 析构");
    }

    public override Object asset
    {
        get
        {
            if (mRequest != null && mRequest.isDone)
            {
                return mRequest.asset;
            }
            return null;
        }
    }

    public override bool UpdateState()
    {
        return !IsCompleted();
    }

    public override bool IsCompleted()
    {
        return mRequest == null || mRequest.isDone;
    }
}

/// <summary>
/// 场景异步加载
/// </summary>
public class LoadSceneFromBundleRequest : LoadAsyncOperation
{
    protected string mAssetBundleName;
    protected string mSceneName;
    protected bool mIsAdditive;

    private AsyncOperation mAsyncRequest;
    private bool  mAllowSceneActivation;

    private bool mIsWaiting = true;

    public LoadSceneFromBundleRequest(string assetbundleName, string sceneName, bool isAdditive)
    {
        mAssetBundleName = assetbundleName;
        mSceneName = sceneName;
        mIsAdditive = isAdditive;
        SetTimeLine(AssetBundleConfig.ConstAsyncLoadSceneTimeLimit);
    }

    ~LoadSceneFromBundleRequest()
    {
         //Debug.Log("~~~~LoadSceneFromBundleRequest 析构");
    }

    public override bool UpdateState()
    {
        mIsWaiting = KeepWaiting();
        return mIsWaiting;
    }

    public override bool IsCompleted()
    {
        return !mIsWaiting;
    }

    private  bool KeepWaiting()
    {
        if (string.IsNullOrEmpty(mAssetBundleName) || string.IsNullOrEmpty(mSceneName))
        {
            Debug.LogError("SceneFromAssetBundleLoadAsyncOperation Error: input name is invalid");
            return false;
        }

        if (TimeMonitor != null && TimeMonitor.Timeout())
        {
            Debug.LogError("LoadAssetFromBundleRequest Error: Time Out, Bundle:" + mAssetBundleName);
            return false;
        }

        if (mAsyncRequest == null)
        {
            string loadError = AssetBundleManager.Instance.GetAsyncLoadError(mAssetBundleName);
            if (loadError != null)
            {
                return false;
            }

            LoadedAssetBundle bundle = AssetBundleManager.Instance.GetLoadedAssetBundle(mAssetBundleName);
            if (bundle != null && bundle.AssetBundle.isStreamedSceneAssetBundle)
            {
                try
                {
                    Debug.Log("###TimeMonitor----------------------------LoadSceneFromBundleRequest 开始加载场景" + mAssetBundleName + "等待资源需要的时间:" + TimeMonitor.Duration);

                    LoadSceneMode mode = mIsAdditive ? LoadSceneMode.Additive : LoadSceneMode.Single;
                    //mAsyncRequest = SceneManager.LoadSceneAsync(mSceneName, mode);
                    mAsyncRequest = SceneMgr.LoadSceneAsync(mSceneName, mode);
                    AsyncSetting = mAsyncRequest;
                }
                catch (Exception e)
                {
                    Debug.LogError("LoadSceneFromBundleRequest Error in Load Bunddle:" + mAssetBundleName + ",ERROR:" + e.ToString());
                    return false;
                }
            }
        }
        else
        {
            if (mAsyncRequest.isDone)
            {
                //AssetBundleManager.Instance.UnloadAssetBundle(mAssetBundleName);
                Debug.Log("###TimeMonitor------------------------------------------LoadSceneFromBundleRequest 场景 异步加载结束" + mAssetBundleName + "持续时时间:" + TimeMonitor.Duration);
                return false;
            }
        }

        return true;//继续等待
    }
}
