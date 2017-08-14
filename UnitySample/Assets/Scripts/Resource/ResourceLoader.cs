using UnityEngine;
using System.IO;
using System.Collections;
using System.Collections.Generic;


namespace Celf
{
    public class ResourceLoader
    {
        private string mRootPath;

        private Dictionary<string, GameObject> mResourceObjects;

        //public bool AsynchLoad { get; set; }

        public ResourceLoader(string rootPath)
        {
            //AsynchLoad = false;
            mRootPath = rootPath;
            mResourceObjects = new Dictionary<string, GameObject>();
            //ResourceService.Instance.ListenOnLowMemory(OnLowMemory);
        }

        public bool Load(string subPath)
        {
            subPath = PathUtil.NormalizePath(subPath);
            GameObject go;
            if (mResourceObjects.TryGetValue(subPath, out go))
            {
                return true;
            }

            string resourcesPath = Path.Combine(mRootPath, subPath);
            go = ResourceService.Instance.LoadGameObject(resourcesPath);

            if (go == null)
            {
                Debug.LogError("load asset failed:" + resourcesPath);
                return false;
            }

            go.SetActive(false);
            mResourceObjects[subPath] = go;
            return true;
        }

        private void Unload(string path)
        {
            path = PathUtil.NormalizePath(path);
            GameObject resourceObject;
            if (mResourceObjects.TryGetValue(path, out resourceObject))
            {
                Object.Destroy(resourceObject);
                mResourceObjects.Remove(path);
            }
        }

        public void UnloadAll(bool gc = false)
        {
            mResourceObjects.Clear();

            if (gc)
            {
                ResourceService.Instance.GC();
            }
        }

        public GameObject Instantiate(string path)
        {
            path = PathUtil.NormalizePath(path);
            GameObject instantiateObject = null;
            if (Load(path))
            {
                instantiateObject = Object.Instantiate(mResourceObjects[path]) as GameObject;
                if (instantiateObject != null)
                {
                    instantiateObject.SetActive(true);
                }
            }

            return instantiateObject;
        }

        private void OnLowMemory()
        {
            UnloadAll();
        }

        private void OnDestroy()
        {
            //ResourceService.Instance.UnlistenOnLowMemory(OnLowMemory);
        }
    }
}
