using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using Celf;

namespace AssetBundles
{
    partial class AssetBundleManager : Singleton<AssetBundleManager>
    {
        [Obsolete("建议使用协程方式处理异步")]
        public IEnumerator GetAssetBundleAsyncWithCallBack(string assetPath, Action<AssetBundle> callback)
        {
            if (string.IsNullOrEmpty(assetPath))
            {
                Debug.LogError("GetAssetBundleAsync Error: Asset Path is empty");
                if (callback != null)
                    callback(null);
                yield break;
            }

            yield return StartCoroutine(GetAssetBundleAysncInternal(assetPath, callback));
        }

        private IEnumerator GetAssetBundleAysncInternal(string assetPath, Action<AssetBundle> callback)
        {
            string bundleName = GetAssetBundleName(assetPath);

            yield return StartCoroutine(LoadAssetAsyncWithCallBack(bundleName));

            AssetBundle ab = null;
            LoadedAssetBundle loadedAssetBundle = GetLoadedAssetBundle(bundleName);
            if (loadedAssetBundle != null)
            {
                ab = loadedAssetBundle.AssetBundle;
            }

            if (callback != null)
            {
                callback(ab);
            }
        }

        /// <summary>
        /// 异步加载接口
        /// </summary>
        [Obsolete("建议使用协程方式处理异步")]
        public void LoadAssetAsyncWithCallback<T>(string assetPath, Action<T> callback, bool unloadDependencies = true) where T : UnityEngine.Object
        {
            StartCoroutine(LoadAssetAsyncWithCallbackInternal<T>(assetPath, callback, unloadDependencies));
        }

        /// <summary>
        /// 内部异步加载接口
        /// </summary>
        /// <param name="assetPath"></param>
        /// <param name="callback"></param>
        /// <param name="unloadDependencies"></param>
        /// <returns></returns>
        /// NOTE:无实例化
        private IEnumerator LoadAssetAsyncWithCallbackInternal<T>(string assetPath, Action<T> callback, bool unloadDependencies = true) where T : UnityEngine.Object
        {
            string bundleName = GetAssetBundleName(assetPath);
            string assetName = assetPath.Substring(assetPath.LastIndexOf("/") + 1);

            yield return StartCoroutine(LoadAssetAsyncWithCallBack(bundleName));

            T res = null;
            if (mLoadedAssetBundleMap.ContainsKey(bundleName) && mLoadedAssetBundleMap[bundleName].AssetBundle != null)
            {
                AssetBundleRequest request = mLoadedAssetBundleMap[bundleName].AssetBundle.LoadAssetAsync<T>(assetName);
                yield return request;

                res = request.asset as T;
                AssetBundleUtil.ResetShaderInEditor(res);
            }

            if (callback != null)
            {
                callback(res);
            }

            UnloadAssetBundle(bundleName, unloadDependencies);
        }

        /// <summary>
        /// 异步加载资源
        /// </summary>
        /// <param name="assetBundleName"></param>
        /// <param name="checkDependencies">是否检查依赖项</param>
        /// <returns></returns>
        protected IEnumerator LoadAssetAsyncWithCallBack(string assetBundleName, bool checkDependencies = true)
        {
            if (checkDependencies)
            {
                yield return StartCoroutine(LoadDependenciesAsyncWithCallBack(assetBundleName));
            }
            yield return StartCoroutine(LoadAssetBundleFromFileAsyncWithCallBack(assetBundleName));
        }

        /// <summary>
        /// 异步加载依赖项
        /// </summary>
        /// <param name="assetBundleName"></param>
        /// <returns></returns>
        protected IEnumerator LoadDependenciesAsyncWithCallBack(string assetBundleName)
        {
            if (GetAssetBundleManifest() == null)
            {
                Debug.LogError("Please call OnInitialize() to initialize GetAssetBundleManifest");
                yield break;
            }

            string[] dependencies = GetDependenciesList(assetBundleName);
            if (dependencies.Length == 0)
            {
                yield break;
            }

            if (!mDependencieMap.ContainsKey(assetBundleName))
            {
                mDependencieMap.Add(assetBundleName, dependencies);
            }

            for (int i = 0; i < dependencies.Length; i++)
            {
                yield return StartCoroutine(LoadAssetBundleFromFileAsyncWithCallBack(dependencies[i]));
            }
        }

        /// <summary>
        /// 异步加载本地文件
        /// </summary>
        protected IEnumerator LoadAssetBundleFromFileAsyncWithCallBack(string assetBundleName)
        {
            if (string.IsNullOrEmpty(assetBundleName))
            {
                yield break;
            }

            LoadedAssetBundle bundle = null;
            mLoadedAssetBundleMap.TryGetValue(assetBundleName, out bundle);
            if (bundle != null)
            {
                bundle.ReferencedCount++;
                yield break;
            }

            string url = AssetBundleConfig.GetAssetBundlePath(assetBundleName);
            Print(">> LoadAssetBundleFromFileAysc url:" + url);

            var bundleLoadRequest = AssetBundle.LoadFromFileAsync(url);
            yield return bundleLoadRequest;

            mLoadedAssetBundleMap.TryGetValue(assetBundleName, out bundle); //TODO 
            if (bundle != null)
            {
                bundle.ReferencedCount++;
                yield break;
            }

            AssetBundle myLoadedAssetBundle = bundleLoadRequest.assetBundle;
            if (myLoadedAssetBundle == null)
            {
                Debug.Log("Failed to load AssetBundle!");
                yield break;
            }

            bundle = new LoadedAssetBundle(myLoadedAssetBundle);
            mLoadedAssetBundleMap.Add(assetBundleName, bundle);
        }

        /// <summary>
        /// 从web进行下载，TODO 5.3版本后 建议优化为 UnityWebRequest
        /// </summary>
        protected IEnumerator LoadAssetBundleInternalFromWeb(string assetBundleName)
        {
            //Debug.Log("LoadAssetBundleInternalAsync src:" + assetBundleName);

            if (string.IsNullOrEmpty(assetBundleName))
            {
                yield break;
            }

            LoadedAssetBundle bundle = null;
            mLoadedAssetBundleMap.TryGetValue(assetBundleName, out bundle);
            if (bundle != null)
            {
                bundle.ReferencedCount++;
                yield break;
            }

            WWW www = null;
            if (!mLoadingWWWMap.ContainsKey(assetBundleName))
            {
                string url = AssetBundleConfig.GetAssetBundleBundleUrl(assetBundleName);
                Print(">> LoadAssetBundleInternalAsync url:" + url);
                www = WWW.LoadFromCacheOrDownload(url, GetAssetBundleManifest().GetAssetBundleHash(assetBundleName), 0);
                mLoadingWWWMap.Add(assetBundleName, www);
            }

            www = mLoadingWWWMap[assetBundleName];
            yield return www;

            mLoadedAssetBundleMap.TryGetValue(assetBundleName, out bundle);
            if (bundle != null)
            {
                bundle.ReferencedCount++;
                yield break;
            }

            if (www.error != null)
            {
                Debug.LogError("Load AssetBundle @[" + assetBundleName + "] ERROR! [" + www.error + "]");
                yield break;
            }

            if (www.isDone)
            {
                bundle = new LoadedAssetBundle(www.assetBundle);
                mLoadedAssetBundleMap.Add(assetBundleName, bundle);
                mLoadingWWWMap.Remove(assetBundleName);
                www.Dispose();
                www = null;
            }
        }
    }
}