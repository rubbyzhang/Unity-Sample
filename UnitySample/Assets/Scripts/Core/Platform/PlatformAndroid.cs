using UnityEngine;
using System;
using System.Collections.Generic;

namespace Core
{
    internal class PlatformAndroid : Platform
    {
        //private static string mDataRoot = Application.streamingAssetsPath;
        private static string mDataRoot = Application.persistentDataPath + "/data/";

        public override string DataRoot
        {
            get { return mDataRoot; }
        }

        public override void Init()
        {
            Debug.Log("PlatformAndroid.Init...");
        }

        public override void Release()
        {
        }

        public override string GetPath(string relativePath)
        {
            string fullPath = string.Format("{0}{1}", DataRoot, StandardlizePath(relativePath));
            if (fullPath.StartsWith("jar:file://"))
            {
                fullPath = fullPath.Substring(4);
            }
            return fullPath;
        }

        public override string GetBundleURL(string relativePath)
        {
            string fullPath;
            if (DataRoot.StartsWith("jar:file://"))
            {
                fullPath = string.Format("{0}{1}", DataRoot, StandardlizePath(relativePath));
            }
            else
            {
                fullPath = string.Format("file://{0}{1}", DataRoot, StandardlizePath(relativePath));
            }
            return fullPath;
        }

        public override string GetWritePath(string relativePath)
        {
            return GetPath(relativePath);
        }
    }
}