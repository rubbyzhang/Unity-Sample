
#if UNITY_EDITOR

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using AssetBundles;
using UnityEditor;
using UnityEngine;

public class AssetBundlePackageTool
{
    static List<string> mShaderFiles = new List<string>();

    public static void Reset()
    {
        ClearAssetBundlesNameBefore();
        mShaderFiles.Clear();
    }

    public static List<string> GetAssetFileList(BundleType type)
    {
        List<string> assetFileList = new List<string>();

        PackTargetConfig[] targetInfos = AssetBundleConfig.GetPackTargetConfig(type);
        if (targetInfos == null || targetInfos.Length == 0)
        {
            return assetFileList;
        }

        List<string> allFile = new List<string>();

        foreach (PackTargetConfig targetInfo in targetInfos)
        {
            for (int i = 0; i < targetInfo.AssetPath.Length; i++)
            {
                string assetPath = targetInfo.AssetPath[i];

                string fullPath = AssetBundleUtil.ToFullPath(assetPath);

                allFile.Clear();
                allFile.AddRange(GetAllFiles(fullPath, targetInfo.Type));

                if (targetInfo.PackStrategy == PackStrategy.Default)
                {
                    assetFileList.AddRange(allFile);
                }
            }
        }

        assetFileList = assetFileList.Distinct().ToList();
        return assetFileList;
    }

    public static void BuildAssetBundle(BundleType type, BuildTarget target, string outputPath  , bool clearBeforeBuildBundle = false)
    {
        double time_begin = EditorApplication.timeSinceStartup;

        Debug.Log(">>>>>>>> AssetBundle Build Start Build");
        if (string.IsNullOrEmpty(outputPath))
        {
            DebugError("输出路径为空");
            return;
        }

        if (target != EditorUserBuildSettings.activeBuildTarget)
        {
//            EditorUserBuildSettings.SwitchActiveBuildTarget(BuildPipeline.GetBuildTargetGroup(target), target);
        }

        Reset();

        CreateOutputFold(outputPath, clearBeforeBuildBundle);

        PackTargetConfig[] targetInfos = AssetBundleConfig.GetPackTargetConfig(type);
        if (targetInfos == null || targetInfos.Length == 0)
        {
            return;
        }

        List<string> allFile = new List<string>();

        foreach (PackTargetConfig targetInfo in targetInfos)
        {
            for (int i = 0; i < targetInfo.AssetPath.Length; i++)
            {
                string assetPath = targetInfo.AssetPath[i];

                string fullPath = AssetBundleUtil.ToFullPath(assetPath);

                allFile.Clear();
                allFile.AddRange(GetAllFiles(fullPath, targetInfo.Type, targetInfo.Dependency));

                if (targetInfo.PackStrategy == PackStrategy.Default)
                {
                    PackSome(allFile);
                }
                else if (targetInfo.PackStrategy == PackStrategy.One)
                {
                    string assetBundleName = AssetBundleUtil.GetBundleName(assetPath);
                    PackSome(allFile, assetBundleName);
                }
            }
        }

        //Shader
        PackSome(mShaderFiles, AssetBundleConfig.ConstShaderAssetBundleName);

        double time_collection = EditorApplication.timeSinceStartup;
        Debug.Log(">>>>>>>>>>>>>>>>>>>>>>>>>> AssetBundle Build Collection , Time Cost(s):" + (int)(time_collection - time_begin));

        BuildPipeline.BuildAssetBundles(outputPath, BuildAssetBundleOptions.ChunkBasedCompression, target);

        Reset();

        ClearUnusedAssetBundleFiles(outputPath);

        ////delete manifest
        //DeleteAllFiles(outputPath, "*.manifest");
        double time_end = EditorApplication.timeSinceStartup;
        Debug.Log(">>>>>>>>>>>>>>>>>>>>>>>>>> AssetBundle Build Complete , Time Cost(s):" + (int)(time_end - time_collection));

        //AssetDatabase.Refresh();
    }

    static void CreateOutputFold(string outputPath , bool clearBeforeBuildBundle = false)
    {
        if (Directory.Exists(outputPath))
        {
            if (clearBeforeBuildBundle)
            {
                Directory.Delete(outputPath, true);
                Directory.CreateDirectory(outputPath);
            }
        }
        else
        {
            Directory.CreateDirectory(outputPath);
        }
    }

    /// <summary>
    /// 获得所有需要进行打包的文件
    /// </summary>
    private static List<string> GetAllFiles( string fullPath,  BundleType type ,  DependenciesStrategy dependency = DependenciesStrategy.All)
    {
        List<string> targetFiles = GetAllTargetFile(fullPath);
        if (targetFiles.Count == 0)
        {
            return targetFiles;
        }

        for (int i = 0; i < targetFiles.Count; i++)
        {
            targetFiles[i] = AssetBundleUtil.ToProjectPath(targetFiles[i]);
            targetFiles[i] = Normarlize(targetFiles[i]);
        }

        if (dependency != DependenciesStrategy.None)
        {
            targetFiles.AddRange(GetFileDependencies(targetFiles, type,  dependency));
        }

        targetFiles = targetFiles.Distinct().ToList();
        targetFiles.RemoveAll(Directory.Exists);
        targetFiles.Sort();

        return targetFiles;
    }

    /// <summary>
    /// 获得全部需要打包的文件(不做依赖分析)
    /// </summary>
    private static List<string> GetAllTargetFile(string fullPath)
    {
        List<string> fileList = new List<string>();
        if (string.IsNullOrEmpty(fullPath))
        {
            return fileList;
        }

        DirectoryInfo folder = new DirectoryInfo(fullPath);
        if (!folder.Exists)
        {
            if (File.Exists(fullPath))
            {
                fileList.Add(fullPath);
            }
            else
            {
                DebugError(" fullPath" + fullPath + "必须为文件夹或者单个有效文件");
            }

            return fileList;
        }

        FileSystemInfo[] files = folder.GetFileSystemInfos();
        int length = files.Length;

        for (int i = 0; i < length; i++)
        {
            if (files[i] is DirectoryInfo)
            {
                fileList.AddRange(GetAllTargetFile(files[i].FullName));
            }
            else
            {
                string path = AssetBundleUtil.Normarlize(files[i].FullName);
                fileList.Add(path);
            }
        }

        fileList = fileList.Distinct().ToList();
        fileList.RemoveAll(t => t.EndsWith(".meta"));
        fileList.RemoveAll(Directory.Exists);

        return fileList;
    }

    public static List<string> GetFileDependencies(List<string> projectPaths, BundleType type  , DependenciesStrategy dependency = DependenciesStrategy.All)
    {
        List<string> res = new List<string>();
        if (projectPaths == null || projectPaths.Count == 0)
        {
            return res;
        }

        string[] dependencies = AssetDatabase.GetDependencies(projectPaths.ToArray(), dependency == DependenciesStrategy.All);
        if (dependencies.Length <= 0)
        {
            return res;
        }

        foreach (string projectPath in dependencies)
        {
            if (projectPath.Contains("default resources") || projectPath.Contains("builtin_extra"))
            {
                Debug.LogError("——————————————————————————————————————————————内置资源：" + projectPath);
                continue;
            }


            if (res.Contains(projectPath))
            {
                continue;
            }

            if (CheckShaderFile(projectPath))
            {
                continue;
            }

            if (!CheckFileType(projectPath, type))
            {
                continue;
            }

            //if (IsNeedFile(projectPath, type))
            {
                res.Add(projectPath);
                DebugLog("### Valid CollectDependencies File Name:" + projectPath);
            }
        }

        for (int i = 0; i < res.Count; i++)
        {
            res[i] = AssetBundleUtil.Normarlize(res[i]);
        }

        res.RemoveAll(Directory.Exists);
        res.Sort();

        return res;
    }

    /// <summary>
    /// 检测shader文件，如果为shader文件则返回 true
    /// </summary>
    private static bool CheckShaderFile(string srcPath)
    {
        if (string.IsNullOrEmpty(srcPath))
        {
            return false;
        }

        srcPath = AssetBundleUtil.ToProjectPath(srcPath);
        srcPath = srcPath.ToLower();

        if (srcPath.EndsWith(".mat"))
        {
            string[] dependencies = AssetDatabase.GetDependencies(srcPath, true);
            foreach (string path in dependencies)
            {
                if (path.ToLower().EndsWith(".shader"))
                {
                    if (!mShaderFiles.Contains(path))
                    {
                        DebugLog("### Valid CollectDependencies Shader File Name:" + path);
                        mShaderFiles.Add(path);
                    }
                }
            }
        }
        
        if (srcPath.EndsWith(".shader"))
        {
            if (!mShaderFiles.Contains(srcPath))
            {
                DebugLog("### Valid CollectDependencies Shader File Name:" + srcPath);
                mShaderFiles.Add(srcPath);
            }

            return true;
        }

        return false;
    }


    /// <summary>
    /// 检测文件类型是否为需要打包的类型， 不同的目标类型可能采用不用的文件类型判断； true表示有效文件
    /// </summary>
    private static bool CheckFileType(string srcPath , BundleType type = BundleType.Max)
    {
        if (string.IsNullOrEmpty(srcPath))
        {
            return false;
        }

        List<string> keywords = AssetBundleConfig.GetIgnoreTypePostfix(type);
        if (keywords == null)
        {
            return true;
        }

        string pathLowCase = srcPath.ToLower();

        foreach (string keyword in keywords)
        {
            if (pathLowCase.EndsWith(keyword.ToLower()))
            {
                return false;
            }
        }

        return true;
    }

    private static void PackSome(List<string> projectPaths, string assetBundleName = "")
    {
        if (projectPaths == null || projectPaths.Count == 0)
        {
            return;
        }

        foreach (string projectPath in projectPaths)
        {
           SetBundleName(projectPath, assetBundleName);
        }
    }

    private static void SetBundleName(string projectPath)
    {
       SetBundleName(projectPath, string.Empty);
    }
    private static void SetBundleName(string projectPath, string assetBundleName)
    {
        projectPath = AssetBundleUtil.ToProjectPath(projectPath);
        if (string.IsNullOrEmpty(projectPath))
        {
            return;
        }

        AssetImporter assetImporter = AssetImporter.GetAtPath(projectPath);
        if (null != assetImporter)
        {
            //如果已经有标签则不再修改,在配置文件顺序上就需要先设置低层次资源
            //否则 后面的如果涉及到该资源的引用（前面是打包在一起的资源，后面是分散打包的情况）可能会修改其AB名字
            if (!string.IsNullOrEmpty(assetImporter.assetBundleName))
            {
                return;
            }

            if (string.IsNullOrEmpty(assetBundleName))
            {
                assetImporter.assetBundleName = GetBundleName(projectPath);
            }
            else
            {
                assetImporter.assetBundleName = assetBundleName;
            }
        }
    }

    /// <summary>
    /// 获得bundle名
    /// </summary>
    /// <param name="assetOrProjectPath">"Asset/..." 或者 Asset文件夹下的路劲,如"Resources/Camera"</param>
    /// <returns></returns>
    public static string GetBundleName(string assetPath)
    {
        if (string.IsNullOrEmpty(assetPath))
        {
            DebugError("GetBundleName: Input is null");
            return null;
        }

        string path = assetPath.ToLower();
        if (assetPath.Contains("Assets"))
        {
            path = assetPath.Substring("Assets".Length + 1);
        }

        string bundleName = path.Replace("/", "_");
        if (bundleName.LastIndexOf(".") >= 0)
        {
            bundleName = bundleName.Substring(0, bundleName.LastIndexOf("."));
        }

        return bundleName + AssetBundleConfig.ConstAssetTail;
    }

    static string Normarlize(string s)
    {
        return s.Replace("\\", "/");
    }

    /// <summary>
    /// 清除设置过的AssetBundleName，避免产生不必要的资源也打包
    /// </summary>
    public static void ClearAssetBundlesNameBefore()
    {
        int length = AssetDatabase.GetAllAssetBundleNames().Length;
        string[] oldAssetBundleNames = new string[length];
        for (int i = 0; i < length; i++)
        {
            oldAssetBundleNames[i] = AssetDatabase.GetAllAssetBundleNames()[i];
        }

        for (int j = 0; j < oldAssetBundleNames.Length; j++)
        {
            AssetDatabase.RemoveAssetBundleName(oldAssetBundleNames[j], true);
        }
    }

    /// <summary>
    /// 清除掉历史打包现在废弃不用的AB文件
    /// </summary>
    public static void ClearUnusedAssetBundleFiles(string outputPath)
    {
        string ManifestName = AssetBundleConfig.GetManitestName();
        string manifestPath = outputPath + "/" + ManifestName;
        AssetBundle assetBundle = AssetBundle.LoadFromFile(manifestPath);
        try
        {
            if (assetBundle != null)
            {
                AssetBundleManifest manifest = assetBundle.LoadAsset("AssetBundleManifest") as AssetBundleManifest;
                string[] values = manifest.GetAllAssetBundles();

                DirectoryInfo folder = new DirectoryInfo(outputPath);
                if (folder.Exists)
                {
                    FileSystemInfo[] files = folder.GetFileSystemInfos();
                    for (int i = 0; i < files.Length; i++)
                    {
                        if (files[i] is DirectoryInfo)
                        {
                            Directory.Delete(files[i].FullName);
                        }
                        else if (files[i].FullName.EndsWith(".meta") || files[i].FullName.EndsWith(".manifest"))
                        {
                            continue;
                        }
                        else
                        {
                            string fullPath = AssetBundleUtil.Normarlize(files[i].FullName);
                            string fileName = fullPath.Substring(fullPath.LastIndexOf('/')+1);

                            if (!values.Contains(fileName) && !fileName.Equals(ManifestName))
                            {
                                Debug.LogWarning("Deleta file @ srcPath [" + files[i].FullName + "]");
                                File.Delete(files[i].FullName);
                                File.Delete(files[i].FullName + ".manifest");
                            }
                        }
                    }
                }
                assetBundle.Unload(true);
            }
        }

        catch (Exception)
        {
            assetBundle.Unload(true);
        }
        
        AssetDatabase.Refresh();
    }

    static void DebugLog(string str)
    {
        //Debug.Log(str);
    }

    static void DebugError(string str)
    {
        Debug.LogError(str);
    }
}


#endif