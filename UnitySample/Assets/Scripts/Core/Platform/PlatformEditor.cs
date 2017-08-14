using UnityEngine;
using System;
using System.Collections.Generic;

namespace Core
{
    internal class PlatformEditor : Platform
    {
        //private static string mDataRoot = Application.dataPath;
        //private static string mDataRoot_win = Application.dataPath + "/../../Build/DataExport/Win32/data/";
        //private static string mDataRoot_android = Application.dataPath + "/../../Build/DataExport/Android/data/";
        //private static string mDataRoot_ios = Application.dataPath + "/../../Build/DataExport/iOS/data/";

        private static string mDataRoot_win = Application.streamingAssetsPath + "/";

        public override string DataRoot
        {
            get { return mDataRoot_win; }
        }

        public override void Init()
        {
//            Debug.Log("PlatformEditor.Init...");
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