using UnityEngine;
using System;
using System.Collections.Generic;

namespace Core
{
    internal class PlatformWin : Platform
    {
        //private static string mDataRoot = Application.dataPath + "/../data/";

        private static string mDataRoot = Application.streamingAssetsPath;

        public override string DataRoot
        {
            get { return mDataRoot; }
        }
        public override void Init()
        {
            Debug.Log("PlatformWin.Init...");
        }

        public override void Release()
        {
        }

        public override string GetPath(string relativePath)
        {
            return string.Format("{0}{1}", DataRoot, StandardlizePath(relativePath));
        }

        public override string GetBundleURL(string relativePath)
        {
            return string.Format("file://{0}{1}", DataRoot, StandardlizePath(relativePath));
        }

        public override string GetWritePath(string relativePath)
        {
            return GetPath(relativePath);
        }
    }
}