using System;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Reflection.Emit;
using System.Text;
using System.Text.RegularExpressions;
using AssetBundles;
using JetBrains.Annotations;
using Object = UnityEngine.Object;

public class BunildInResourceManager
{
    private BuildInResourcetTool mBuildinResTool = null;
    private bool mIsInit = false;

    private  List<string> mReplaceAssetFiles = new List<string>();

    public void Init(bool force = false)
    {
        if (!mIsInit)
        {
            mBuildinResTool = new BuildInResourcetTool();
            mBuildinResTool.Extract(force);
            mIsInit = true;
        }
    }
    
    public void Replace(List<string> assetFileList )
    {
        mReplaceAssetFiles.Clear();
        
        if (assetFileList == null || assetFileList.Count == 0)
        {
            return;
        }

        if (mBuildinResTool == null)
        {
            Debug.LogError("");
        }

        foreach (var assetFile in assetFileList)
        {
            bool isSucess = mBuildinResTool.Replace(assetFile);
            if (isSucess)
            {
                mReplaceAssetFiles.Add(assetFile);
            }
        }
    }

    public void Restore()
    {
        Debug.Log("__________________restore:" + mReplaceAssetFiles.Count);
        if (mReplaceAssetFiles.Count == 0)
        {
            return;
        }

        foreach (var assetPath in mReplaceAssetFiles)
        {
            mBuildinResTool.Restore(assetPath);
        }

        //mReplaceAssetFiles.Clear();
    }
}