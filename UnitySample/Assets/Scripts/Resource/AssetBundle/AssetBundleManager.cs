using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.Linq;
using  UnityEngine.Profiling ;

namespace AssetBundles
{
    public class LoadedAssetBundle
    {
        public AssetBundle AssetBundle;
        public int ReferencedCount;

        public LoadedAssetBundle(AssetBundle assetBundle)
        {
            AssetBundle = assetBundle;
            ReferencedCount = 1;
        }

        internal void Unload()
        {
            if (AssetBundle != null)
            {
                AssetBundle.Unload(false);
            }
        }
    }

    partial class AssetBundleManager : Celf.Singleton<AssetBundleManager>
    {
        private AssetBundleManifest mManifest = null;

        //常驻内存
        private readonly string[] mConstStaticAssetPrefix =
        {
            "artsrc_font",
            "common_shader_asset",
        };

        //不随依赖卸载,需手动卸载
        private readonly string[] mConstManualUnloadAssetPrefix =
        {
            "ui_atlas",
        };

        private Dictionary<string, LoadedAssetBundle> mLoadedAssetBundleMap =  new Dictionary<string, LoadedAssetBundle>();

        private Dictionary<string, string[]> mDependencieMap = new Dictionary<string, string[]>();

        private Dictionary<string, WWW> mLoadingWWWMap = new Dictionary<string, WWW>();

        private List<string> mDownloadingBundles = new List<string>();

        //异步加载过程中需要并发卸载AB资源
        private List<string> mDownloadingUnloadBundles = new List<string>();

        private List<WaitForLoadComplete> mInProgressOperations = new List<WaitForLoadComplete>();

        private Dictionary<string, string> mDownloadingErrors = new Dictionary<string, string>();

        private bool mIsInit = false;

        private void Update()
        {
            UpdateAsyncProcessOperation();
        }
        
        protected override void OnInit()
        {
            Initialize();
        }

        public void Initialize()
        {
            if (!mIsInit)
            {
                LoadManifest();
                InitShader();
                mIsInit = true;
            }
        }

        private void InitShader()
        {
            string shaderName = AssetBundleConfig.ConstShaderAssetBundleName;

            LoadAssetBundleFromFile(shaderName, false);

            if (mLoadedAssetBundleMap.ContainsKey(shaderName))
            {
                AssetBundle bundle = mLoadedAssetBundleMap[shaderName].AssetBundle;
                if (bundle == null)
                {
                    Debug.LogError("Load Shader Asset Fail");
                    return;
                }

                bundle.LoadAllAssets();

                //预加载所有shader
                Shader.WarmupAllShaders();
            }
        }

        /// <summary>
        /// 获取依赖关系数据
        /// </summary>
        private AssetBundleManifest GetAssetBundleManifest()
        {
            if (mManifest == null)
            {
                Initialize();
            }
            return mManifest;
        }

        /// <summary>
        /// Retrieves an asset bundle that has previously been requested via LoadAssetBundle.
        /// Returns null if the asset bundle or one of its dependencies have not been downloaded yet.
        /// </summary>
        public LoadedAssetBundle GetLoadedAssetBundle(string assetBundleName)
        {
            LoadedAssetBundle bundle = null;
            mLoadedAssetBundleMap.TryGetValue(assetBundleName, out bundle);
            if (bundle == null)
            {
                Debug.LogWarning("Get LoadedAssetBundle Name(" + assetBundleName  + ")  资源缺失");
                return null;
            }

            string[] dependencies = null;
            if (!mDependencieMap.TryGetValue(assetBundleName, out dependencies))
            {
                return bundle;
            }

            for (int i = 0; i < dependencies.Length; i++)
            {
                string dependency = dependencies[i];
                LoadedAssetBundle dependentBundle;
                mLoadedAssetBundleMap.TryGetValue(dependency, out dependentBundle);
                if (dependentBundle == null)
                {
                  //  Debug.LogWarning("Get LoadedAssetBundle Name(" + assetBundleName + ")  资源缺失, 缺少依赖资源：" + dependency+")");
                    return null;
                }
            }
            return bundle;
        }

        /// <summary>
        /// 同步加载 Manitest
        /// </summary>
        private void LoadManifest()
        {
            string manifestName = AssetBundleConfig.GetManitestName();
            LoadAssetBundleFromFile(manifestName, false);

            if (mLoadedAssetBundleMap.ContainsKey(manifestName))
            {
                mManifest = mLoadedAssetBundleMap[manifestName].AssetBundle.LoadAsset("AssetBundleManifest") as AssetBundleManifest;
            }
            UnloadAssetBundle(manifestName);
        }

        /// <summary>
        /// 获得Bundle Name，根据 AssetBundleConfig Pack类型从路径中Bundle名字
        /// </summary>
        private string GetAssetBundleName(string assetPath)
        {
            if (string.IsNullOrEmpty(assetPath))
            {
                return string.Empty;
            }

            assetPath = AssetBundleUtil.ToAssetPath(assetPath);

            string bundleName = AssetBundleConfig.GetAssetBundleName(assetPath);
            if (string.IsNullOrEmpty(bundleName))
            {
                bundleName = AssetBundleUtil.GetBundleName(assetPath);
            }

            return bundleName;
        }

        /// <summary>
        /// 获得依赖关系列表
        /// </summary>
        private string[] GetDependenciesList(string assetBundleName)
        {
            string[] fileList = new string[] {};
            if (string.IsNullOrEmpty(assetBundleName))
            {
                return fileList;
            }

            if (null == mManifest)
            {
                Debug.LogError("GetDependenciesList Error: Manifest is miss");
                return fileList;
            }

            string[] dependencies = GetAssetBundleManifest().GetAllDependencies(assetBundleName);
            List<string> validList = dependencies.ToList();
            validList.RemoveAll(t => string.IsNullOrEmpty(t));
            dependencies = validList.ToArray();

            return dependencies;
        }


        #region 同步加载

        /// <summary>
        /// 同步加载资源
        /// </summary>
        private void LoadAssetBundleFromFile(string assetBundleName, bool checkDependencies = true)
        {
            if (checkDependencies)
            {
                LoadDependenciesFromFile(assetBundleName);
            }
            LoadAssetBundleFromFileInternal(assetBundleName);
        }

        /// <summary>
        /// 同步加载依赖项
        /// </summary>
        private void LoadDependenciesFromFile(string assetBundleName)
        {
            if (GetAssetBundleManifest() == null)
            {
                Debug.LogError("Please call OnInitialize() to initialize GetAssetBundleManifest");
                return;
            }

            string[] dependencies = GetDependenciesList(assetBundleName);
            if (dependencies.Length == 0)
            {
                return;
            }

            if (!mDependencieMap.ContainsKey(assetBundleName))
            {
                mDependencieMap.Add(assetBundleName, dependencies);
            }

            for (int i = 0; i < dependencies.Length; i++)
            {
                LoadAssetBundleFromFileInternal(dependencies[i]);
            }
        }

        /// <summary>
        /// 同步加载资源过程
        /// </summary>
        private void LoadAssetBundleFromFileInternal(string assetBundleName)
        {
            if (string.IsNullOrEmpty(assetBundleName))
            {
                return;
            }

            LoadedAssetBundle bundle = null;
            mLoadedAssetBundleMap.TryGetValue(assetBundleName, out bundle);
            if (bundle != null)
            {
                Print("##############LoadAssetBundleFromFileInternal 增加引用 Name:" + assetBundleName + ",引用次数:" + bundle.ReferencedCount);
                bundle.ReferencedCount++;
                return;
            }

            string url = AssetBundleConfig.GetAssetBundlePath(assetBundleName);
            Print(">> 同步 AssetBundle 加载：url:" + assetBundleName);

            AssetBundle assetBundle = null;
            try
            {
                assetBundle = AssetBundle.LoadFromFile(url);
            }
            catch (Exception e)
            {
                Debug.LogError("Load AssetBundle @ [" + url + "], Error [" + e + "]");
            }
            catch
            {
                Debug.LogError("Load AssetBundle @ [" + url + "], native exception!!");
            }

            if (assetBundle != null)
            {
                bundle = new LoadedAssetBundle(assetBundle);
                mLoadedAssetBundleMap.Add(assetBundleName, bundle);
            }
        }

        #endregion

        #region 异步加载

        /// <summary>
        /// 异步加载资源以及依赖资源
        /// </summary>
        /// <param name="assetBundleName"></param>
        private void LoadAssetBundleFromFileAsync(string assetBundleName)
        {
            bool isAlreadyProcessed = LoadAssetBundleFromFileAsyncInternal(assetBundleName);
            if (!isAlreadyProcessed)
            {
                LoadDependenciesFromFileAsync(assetBundleName);
            }
        }

        private void LoadDependenciesFromFileAsync(string assetBundleName)
        {
            string[] dependencies = GetDependenciesList(assetBundleName);
            if (dependencies.Length == 0)
            {
                return;
            }

            if (!mDependencieMap.ContainsKey(assetBundleName))
            {
                mDependencieMap.Add(assetBundleName, dependencies);
            }

            for (int i = 0; i < dependencies.Length; i++)
            {
                LoadAssetBundleFromFileAsyncInternal(dependencies[i]);
            }
        }

        private bool LoadAssetBundleFromFileAsyncInternal(string assetBundleName)
        {
            LoadedAssetBundle bundle = null;
            mLoadedAssetBundleMap.TryGetValue(assetBundleName, out bundle);

            if (bundle != null)
            {
                Print("###########################增加依赖引用：引用对象:" + assetBundleName + ",引用次数:" + bundle.ReferencedCount);
                bundle.ReferencedCount++;
                return true;
            }

            if (mDownloadingBundles.Contains(assetBundleName))
            {
                return true;
            }

            string url = AssetBundleConfig.GetAssetBundlePath(assetBundleName);
            Print("异步AssetBundle下载 URL:" + assetBundleName);

            var option = AssetBundle.LoadFromFileAsync(url);
            mInProgressOperations.Add(new LoadBundleFromFileOperation(assetBundleName, option));
            mDownloadingBundles.Add(assetBundleName);


            return false;
        }

        /// <summary>
        /// 更新异步状态
        /// </summary>
        private void UpdateAsyncProcessOperation()
        {
            for (int i = 0; i < mInProgressOperations.Count;)
            {
                var operation = mInProgressOperations[i];
                if (operation.UpdateState())
                {
                    i++;
                }
                else
                {
                    mInProgressOperations.RemoveAt(i);

                    if (operation is LoadBundleOperation)
                    {
                        ProcessFinishedOperation(operation);
                    }
                }

                //Print("更新异步下载状态：UpdateAsyncProcessOperation：" + mInProgressOperations.Count);
            }

            //等所有加载执行完之后再卸载，避免并发异步情况下资源依赖提前卸载问题
            if (mInProgressOperations.Count == 0 && mDownloadingUnloadBundles.Count != 0)
            {
                for (int i = 0; i < mDownloadingUnloadBundles.Count; ++i)
                {
                    Print("#################### 卸载 AssetBundle资源：" + mDownloadingUnloadBundles[i]);
                    UnloadAssetBundle(mDownloadingUnloadBundles[i],true);
                }
                mDownloadingUnloadBundles.Clear();
            }
        }

        /// <summary>
        /// 异步加载结束处理
        /// </summary>
        /// <param name="operation"></param>
        private void ProcessFinishedOperation(WaitForLoadComplete operation)
        {
            LoadBundleOperation download = operation as LoadBundleOperation;
            if (download == null)
            {
                return;
            }

            if (download.error == null)
            {
                Print("异步资源下载结束,添加到已下载列表 ProcessFinishedOperation Load Complete , Bundle Name :" + download.assetBundleName);
                mLoadedAssetBundleMap.Add(download.assetBundleName, download.assetBundle);
            }
            else
            {
                string msg = string.Format("Failed downloading bundle {0} : {1}", download.assetBundleName , download.error);
                mDownloadingErrors.Add(download.assetBundleName, msg);
                Debug.LogError(msg);
            }

            mDownloadingBundles.Remove(download.assetBundleName);
        }

        public string GetAsyncLoadError(string bundlename)
        {
            if (mDownloadingErrors.ContainsKey(bundlename))
            {
                return mDownloadingErrors[bundlename];
            }
            return null;
        }

        #endregion

        #region unload

        /// <summary>
        /// 强制卸载（不包含静态资源），不涉及依赖资源(现主要处理atlas资源)
        /// </summary>
        /// <param name="assetPath"></param>
        public void ForceUnloadAssetBundle(string assetPath)
        {
            string assetBundleName = GetAssetBundleName(assetPath);
            if (string.IsNullOrEmpty(assetBundleName))
            {
                return;
            }

            //静态资源不卸载
            if (IsStaticAsset(assetBundleName))
            {
                return;
            }

            LoadedAssetBundle bundle = null;
            mLoadedAssetBundleMap.TryGetValue(assetBundleName, out bundle);
            if (bundle == null)
            {
                return;
            }

            bundle.Unload();
            mLoadedAssetBundleMap.Remove(assetBundleName);

            Print("强制卸载 ForceUnloadAssetBundle : Path:" + assetBundleName);
        }

        /// <summary>
        /// 卸载所有依赖资源（不包含静态资源和需要手动卸载的资源）
        /// </summary>
        public void UnloadAllDependencies()
        {
            if (mDependencieMap == null || mDependencieMap.Count == 0)
            {
                return;
            }

            List<string> keys = mDependencieMap.Keys.ToList();
            for (int i = 0; i < keys.Count; i++)
            {
                UnloadDependencies(keys[i]);
            }
        }

        /// <summary>
        /// 卸载所有AssetBundle（不包含静态资源和需要手动卸载的资源）
        /// </summary>
        public void UnloadAllAssetBundle()
        {
            if (mLoadedAssetBundleMap == null || mLoadedAssetBundleMap.Count == 0)
            {
                return;
            }

            List<string> keys = mLoadedAssetBundleMap.Keys.ToList();
            for (int i = 0; i < keys.Count; i++)
            {
                UnloadAssetBundle(keys[i]);
            }

            UnloadAllDependencies();
        }

        public void UnloadAssetBundleByPath(string assetPath, bool checkDependencies = true)
        {
            string assetBundleName = GetAssetBundleName(assetPath);
            UnloadAssetBundle(assetBundleName,checkDependencies);
        }

        /// <summary>
        /// 卸载AssetBundle（不包含静态资源和需要手动卸载的资源）
        /// </summary>
        public void UnloadAssetBundle(string assetBundleName, bool checkDependencies = true)
        {
            UnloadAssetBundleInternal(assetBundleName);
            if (checkDependencies)
            {
                UnloadDependencies(assetBundleName);
            }
        }

        private void UnloadDependencies(string assetBundleName, bool isForce = false)
        {
            string[] dependencies = null;
            if (!mDependencieMap.TryGetValue(assetBundleName, out dependencies))
            {
                return;
            }

            for (int i = 0; i < dependencies.Length; i++)
            {
                string dependency = dependencies[i];
                UnloadAssetBundleInternal(dependency);
            }

            mDependencieMap.Remove(assetBundleName);
        }

        /// <summary>
        /// 卸载资源（不包含静态资源和需要手动卸载的资源）
        /// </summary>
        /// <param name="assetBundleName"></param>
        private void UnloadAssetBundleInternal(string assetBundleName)
        {
            if (IsStaticAsset(assetBundleName))
            {
                //Print("UnloadAssetBundleInternal 静态资源" + assetBundleName);
                return;
            }

            if (IsManualUnloadAsset(assetBundleName))
            {
                Print("UnloadAssetBundleInternal 需手动卸载资源:" + assetBundleName);
                return;
            }

            LoadedAssetBundle bundle = null;
            mLoadedAssetBundleMap.TryGetValue(assetBundleName, out bundle);
            if (bundle == null)
            {
                return;
            }

            if (--bundle.ReferencedCount == 0)
            {
                bundle.Unload();
                mLoadedAssetBundleMap.Remove(assetBundleName);
                Print("UnloadAssetBundleInternal 资源卸载: Path:" + assetBundleName);
            }
            else
            {
                Print("##########################引用对象:" + assetBundleName + "引用次数:" + bundle.ReferencedCount) ;
            }
        }

        /// <summary>
        /// 是否为常驻内存资源
        /// </summary>
        private bool IsStaticAsset(string assetBundleName)
        {
            if (string.IsNullOrEmpty(assetBundleName))
            {
                return false;
            }

            for (int i = 0; i < mConstStaticAssetPrefix.Length; i++)
            {
                if (assetBundleName.StartsWith(mConstStaticAssetPrefix[i]))
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// 是否为手动卸载资源
        /// </summary>
        private bool IsManualUnloadAsset(string assetBundleName)
        {
            if (string.IsNullOrEmpty(assetBundleName))
            {
                return false;
            }

            for (int i = 0; i < mConstManualUnloadAssetPrefix.Length; i++)
            {
                if (assetBundleName.StartsWith(mConstManualUnloadAssetPrefix[i]))
                {
                    return true;
                }
            }
            return false;
        }

        #endregion

        #region Download from web 

        /// <summary>
        /// 异步加载资源以及依赖资源
        /// </summary>
        /// <param name="assetBundleName"></param>
        [Obsolete("当前框架下异步尽量使用LoadAssetBundleFromFileAsync接口，Unity5.3之后 建议优化为 UnityWebRequest 进行网络下载")]
        public void LoadAssetBundleFromWebAsync(string assetBundleName)
        {
            bool isAlreadyProcessed = LoadAssetBundleFromWebInternal(assetBundleName);
            if (!isAlreadyProcessed)
            {
                LoadDependenciesFromWebAsync(assetBundleName);
            }
        }

        private void LoadDependenciesFromWebAsync(string assetBundleName)
        {
            string[] dependencies = GetDependenciesList(assetBundleName);
            if (dependencies.Length == 0)
            {
                return;
            }

            if (!mDependencieMap.ContainsKey(assetBundleName))
            {
                mDependencieMap.Add(assetBundleName, dependencies);
            }

            for (int i = 0; i < dependencies.Length; i++)
            {
                LoadAssetBundleFromWebInternal(dependencies[i]);
            }
        }

        protected bool LoadAssetBundleFromWebInternal(string assetBundleName)
        {
            LoadedAssetBundle bundle = null;
            mLoadedAssetBundleMap.TryGetValue(assetBundleName, out bundle);

            if (bundle != null)
            {
                bundle.ReferencedCount++;
                return true;
            }

            // @TODO: Do we need to consider the referenced count of WWWs?
            // In the demo, we never have duplicate WWWs as we wait LoadAssetAsync()/LoadLevelAsync() to be finished before calling another LoadAssetAsync()/LoadLevelAsync().
            // But in the real case, users can call LoadAssetAsync()/LoadLevelAsync() several times then wait them to be finished which might have duplicate WWWs.
            if (mDownloadingBundles.Contains(assetBundleName))
            {
                return true;
            }

            WWW download = null;
            string url = AssetBundleConfig.GetAssetBundleBundleUrl(assetBundleName);

            download = WWW.LoadFromCacheOrDownload(url, mManifest.GetAssetBundleHash(assetBundleName), 0);
            mInProgressOperations.Add(new LoadBundleFromWebOperation(assetBundleName, download));

            mDownloadingBundles.Add(assetBundleName);

            Print("LoadAssetBundleFromWebInternal   URL:" + url);

            return false;
        }

        #endregion
        //--------------------------------------------------------------------
        #region  Other
        private List<AssetBundle> GetAllLoadedAssetBundle()
        {
            List<AssetBundle> m_AB = new List<AssetBundle>();
            foreach (KeyValuePair<string, LoadedAssetBundle> mLoadedAssetBundle in mLoadedAssetBundleMap)
            {
                if (mLoadedAssetBundle.Value.AssetBundle != null)
                {
                    m_AB.Add(mLoadedAssetBundle.Value.AssetBundle);
                }
            }
            return m_AB;
        }

        public void PrintAllLoadedAssetBundleName()
        {
            List<AssetBundle> m_AB = new List<AssetBundle>();
            foreach (KeyValuePair<string, LoadedAssetBundle> mLoadedAssetBundle in mLoadedAssetBundleMap)
            {
                Print("_____________PrintAllLoadedAssetBundleName, Name:" + mLoadedAssetBundle.Key);
            }
        }

        private void Print(string str)
        {
            Debug.Log(str);
        }

        #endregion
    }
}