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
    private BuildInResourcetTool mBuildinResTool = new BuildInResourcetTool();
    private bool mIsInit = false;
    private  List<string> mReplaceAssetFiles = new List<string>();

    public void Init(bool force = false)
    {
        if (!mIsInit)
        {
            mBuildinResTool.Extract(force);
            mIsInit = true;
        }
    }

    public void CopyShader()
    {
        string srcShaderDir = Application.dataPath + "/../../BuildInShader";
        string dstShaderDir = AssetBundleUtil.ToFullPath(mBuildinResTool.ConstReplaceShaderAssetFolder);

        CopyDir(srcShaderDir,dstShaderDir);
    }

    public void DeleteShader()
    {
        string dstShaderDir = AssetBundleUtil.ToFullPath(mBuildinResTool.ConstReplaceShaderAssetFolder);
        DeleteDir(dstShaderDir);
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

    public void CopyFile(string srcPath, string dstPath)
    {
        string dstDir = Path.GetDirectoryName(dstPath);
        if (!Directory.Exists(dstDir))
        {
            Directory.CreateDirectory(dstDir);
        }

        if (File.Exists(dstPath))
        {
            File.SetAttributes(dstPath, FileAttributes.Normal);
        }

        File.Copy(srcPath, dstPath, true);
        Debug.Log(string.Format("CopyFile: {0} => {1}", srcPath, dstPath));
    }

    public void MoveFile(string filePath, string toPath)
    {
        if (!File.Exists(filePath))
        {
            return;
        }

        string toDir = Path.GetDirectoryName(toPath);
        if (!Directory.Exists(toDir))
        {
            Directory.CreateDirectory(toDir);
        }

        try
        {
            File.Move(filePath, toPath);
        }
        catch (Exception e)
        {
            Debug.Log("Move Fail From path:" + filePath + " to path:" + toPath);
            throw e;
        }
    }

    public void CopyDir(string srcDir, string dstDir, string pattern = null)
    {
        if (!Directory.Exists(srcDir))
        {
            return;
        }

        if (!Directory.Exists(dstDir))
        {
            Directory.CreateDirectory(dstDir);
        }

        string[] strDirs = Directory.GetDirectories(srcDir);
        foreach (string strdir in strDirs)
        {
            string dir = Path.GetFileName(strdir);
            CopyDir(Path.Combine(srcDir, dir), Path.Combine(dstDir, dir), pattern);
        }

        string[] files = null;
        if (string.IsNullOrEmpty(pattern))
        {
            files = Directory.GetFiles(srcDir);
        }
        else
        {
            files = Directory.GetFiles(srcDir, pattern);
        }

        foreach (string s in files)
        {
            string fileName = Path.GetFileName(s);
            string destFile = Path.Combine(dstDir, fileName);
            File.Copy(s, destFile, true);
        }
    }

    //move "a/dir/" to "b/dir"
    public void MoveDir(string srcDir, string dstDir)
    {
        if (!Directory.Exists(srcDir))
        {
            return;
        }

        DirectoryInfo parentInfo = Directory.GetParent(dstDir);
        if (parentInfo == null)
        {
            return;
        }

        if (!parentInfo.Exists)
        {
            Directory.CreateDirectory(parentInfo.FullName);
        }
        else
        {
            DeleteDir(dstDir);
        }

        Directory.Move(srcDir, dstDir);
    }

    public void DeleteDir(string dir)
    {
        if (Directory.Exists(dir))
        {
            string[] strDirs = Directory.GetDirectories(dir);
            foreach (string strdir in strDirs)
            {
                DeleteDir(strdir);
            }

            string[] strFiles = Directory.GetFiles(dir);
            foreach (string strFile in strFiles)
            {
                if (File.Exists(strFile))
                {
                    File.SetAttributes(strFile, FileAttributes.Normal);
                    File.Delete(strFile);
                }
            }

            Directory.Delete(dir);
        }
    }
}