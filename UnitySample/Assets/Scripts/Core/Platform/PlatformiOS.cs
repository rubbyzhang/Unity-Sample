using UnityEngine;
using System;
using System.Collections.Generic;
using System.IO;

namespace Core
{
    internal class PlatformiOS : Platform
    {
        private static string mDataRoot = Application.persistentDataPath + "/data/";

        public override string DataRoot
        {
            get { return mDataRoot; }
        }

        public override void Init()
        {
            Debug.Log("PlatformiOS.Init...");
        }

        public override void Release()
        {
        }

        public override string GetPath(string relativePath)
        {
            string fullPath = string.Format("{0}{1}", DataRoot, StandardlizePath(relativePath));
            if (File.Exists(fullPath))
            {
                return fullPath;
            }

            fullPath = string.Format("{0}/../data/{1}", Application.dataPath, StandardlizePath(relativePath));
            return fullPath;
        }

        public override string GetBundleURL(string relativePath)
        {
            string fullPath = string.Format("{0}{1}", DataRoot, StandardlizePath(relativePath));
            if (File.Exists(fullPath))
            {
                fullPath = string.Format("file://{0}", fullPath);
                return fullPath;
            }

            fullPath = string.Format("file://{0}/../data/{1}", Application.dataPath, StandardlizePath(relativePath));
            return fullPath;
        }

        public override string GetWritePath(string relativePath)
        {
            return string.Format("{0}{1}", DataRoot, StandardlizePath(relativePath));
        }
    }
}