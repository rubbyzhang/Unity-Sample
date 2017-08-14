using UnityEngine;
using System;
using System.Collections.Generic;

namespace Core
{
    internal abstract class Platform
    {
        private static Platform m_Instance = null;

        public static Platform Instance
        {
            get
            {
                if (m_Instance == null)
                {
                    CreateInstance();
                }
                return m_Instance;
            }
        }

        public static void CreateInstance()
        {
            switch (Application.platform)
            {
                case RuntimePlatform.WindowsEditor:
                case RuntimePlatform.OSXEditor:
                {
                    m_Instance = new PlatformEditor();
                }
                    break;
                case RuntimePlatform.WindowsPlayer:
                case RuntimePlatform.OSXPlayer:
                {
                    m_Instance = new PlatformWin();
                }
                    break;
                case RuntimePlatform.Android:
                {
                    m_Instance = new PlatformAndroid();
                }
                    break;
                case RuntimePlatform.IPhonePlayer:
                {
                    m_Instance = new PlatformiOS();
                }
                    break;
                default:
                    break;
            }
        }

        public abstract string DataRoot { get; }
        public abstract void Init();
        public abstract void Release();
        public abstract string GetPath(string relativePath);
        public abstract string GetBundleURL(string relativePath);
        public abstract string GetWritePath(string relativePath);

        protected string StandardlizePath(string path)
        {
            //string pathReplace = path.Replace(@"\", @"/");
            //string pathLower = pathReplace.ToLower();
            //return pathLower;
            return PathUtil.NormalizePath(path);
        }


        public bool isAndroid
        {
            get { return Application.platform == RuntimePlatform.Android; }
        }

        public bool isIos
        {
            get { return Application.platform == RuntimePlatform.IPhonePlayer; }
        }

        public bool isEditor
        {
            get
            {
                return Application.platform == RuntimePlatform.WindowsEditor ||
                       Application.platform == RuntimePlatform.OSXEditor;
            }
        }
    }
}