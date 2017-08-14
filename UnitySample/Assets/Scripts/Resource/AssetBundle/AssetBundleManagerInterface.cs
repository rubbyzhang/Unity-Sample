using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using Celf;

namespace AssetBundles
{
    partial class AssetBundleManager : Singleton<AssetBundleManager>
    {
        /// <summary>
        /// 同步加载资源, 默认加载之后会卸载AssetBundle资源
        /// </summary>
        public T LoadAsset<T>(string assetPath, bool unloadDependencies = true)
            where T : UnityEngine.Object
        {
            string bundleName = GetAssetBundleName(assetPath);
            string assetName = assetPath.Substring(assetPath.LastIndexOf("/") + 1);

            Print("LoadObjectFromAssetBundle assetPath:" + assetPath + ", bundleName :" + bundleName + ", assetName :" + assetName);

            return LoadAsset<T>(bundleName, assetName, unloadDependencies);
        }

        private T LoadAsset<T>(string bundleName, string assetName, bool unloadDependencies = true)
            where T : UnityEngine.Object
        {
            T res = null;

            LoadAssetBundleFromFile(bundleName);

            if (mLoadedAssetBundleMap.ContainsKey(bundleName) && mLoadedAssetBundleMap[bundleName].AssetBundle != null)
            {
                res = mLoadedAssetBundleMap[bundleName].AssetBundle.LoadAsset<T>(assetName);
                AssetBundleUtil.ResetShaderInEditor(res);
            }
            UnloadAssetBundle(bundleName, unloadDependencies);
            return res;
        }

        /// <summary>
        /// 异步加载接口 ,默认加载结束后卸载AssetBundle资源
        /// </summary>
        public LoadAssetRequest LoadAssetAsync<T>(string assetPath, bool unloadDependencies = true) where T : UnityEngine.Object
        {
            string bundleName = GetAssetBundleName(assetPath);
            string assetName = assetPath.Substring(assetPath.LastIndexOf("/") + 1);

            Print("------------------------------------------异步加载资源 LoadAssetAsync bundleName:" + bundleName + "    assetName:" + assetName);

            return LoadAssetAsync<T>(bundleName, assetName, unloadDependencies);
        }

        private LoadAssetRequest LoadAssetAsync<T>(string bundleName, string assetName,  bool unloadDependencies = true) where T : UnityEngine.Object
        {
            if (string.IsNullOrEmpty(bundleName) || string.IsNullOrEmpty(assetName))
            {
                Debug.LogError("LoadFromAssetBundleAsync Error: Input is null");
                return null;
            }

            LoadAssetBundleFromFileAsync(bundleName);

            LoadAssetRequest operation = new LoadAssetFromBundleRequest(bundleName, assetName, typeof(T), unloadDependencies);

            if (unloadDependencies)
            {
                mDownloadingUnloadBundles.Add(bundleName);
            }

            mInProgressOperations.Add(operation);

            return operation;
        }

        /// <summary>
        /// 异步加载场景, 默认加载后卸载AssetBundle资源
        /// </summary>
        public LoadAsyncOperation LoadSceneAsync(string assetPath, bool isAdditive)
        {
            assetPath = AssetBundleUtil.ToAssetPath(assetPath);

            string bundleName = GetAssetBundleName(assetPath);
            string assetName = assetPath.Substring(assetPath.LastIndexOf("/") + 1);

            Print("LoadSceneAsync  bundleName:" + bundleName + "    assetName:" + assetName);

            LoadAssetBundleFromFileAsync(bundleName);

            //mDownloadingUnloadBundles.Add(bundleName);

            LoadAsyncOperation operation = new LoadSceneFromBundleRequest(bundleName, assetName, isAdditive);

            mInProgressOperations.Add(operation);

            return operation;
        }

        /// <summary>
        /// 同步获取AssetBundle, 注意卸载
        /// </summary>
        public AssetBundle GetAssetBundle(string assetPath)
        {
            string bundleName = GetAssetBundleName(assetPath);

            LoadAssetBundleFromFile(bundleName);

            LoadedAssetBundle bundle = GetLoadedAssetBundle(bundleName);
            //不检测依赖
            //LoadedAssetBundle bundle;
            //mLoadedAssetBundleMap.TryGetValue(bundleName,out bundle);
            if (bundle != null)
            {
                return bundle.AssetBundle;
            }
            return null;
        }

        public LoadBundleFromFileOperation GetAssetBundleAsync(string assetPath)
        {
            return null;
        }
    }
}