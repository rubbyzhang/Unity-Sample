using System;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using AssetBundles;
using JetBrains.Annotations;
using Object = UnityEngine.Object ;

public static class GameBuildPipeline_AssetBundle
{
    public static void BuildPlatformAll(BuildTarget target, BundleType type = BundleType.Max)
    {
        GameBuildPipeline_Platform.StartTimeRecorder("Build AssetBundle");

        string bundlePath = GetBundleSavePath(target);
        if (target == BuildTarget.Android)
        {
            AssetBundlePackageTool.BuildAssetBundle(type, BuildTarget.Android, bundlePath, false);
        }
        else if (target == BuildTarget.iOS)
        {
            AssetBundlePackageTool.BuildAssetBundle(type, BuildTarget.iOS, bundlePath, false);
        }
        else if (target == BuildTarget.StandaloneWindows)
        {
            AssetBundlePackageTool.BuildAssetBundle(type, BuildTarget.StandaloneWindows, bundlePath, false);
        }
        else
        {
            Debug.LogError("Critical Error. BuildTarget not support: " + target.ToString());
        }

        GameBuildPipeline_Platform.StopTimeRecorder("Build AssetBundle");
    }

    public static string GetBundleSavePath(BuildTarget target)
    {
        return string.Format("{0}/../{1}/{2}",Application.dataPath, GameBuildPipeline_Platform.GetBuildDataExportPath(target),
            AssetBundleConfig.AssetBundlesPath);
    }

    public static void RemoveAllBundleAsset(BuildTarget target)
    {
        string exportVFSRoot = GameBuildPipeline_Platform.GetBuildDataExportPath(target) + "/";
        GameBuildPipeline_Platform.DeleteDir(exportVFSRoot + "assetbundle/");
    }
    //---------------------------------------------------------------------------------------
    [MenuItem("Build/Asset Bundle/Custom Pack Window")]
    static void BundlePackCustomWindow()
    {
        AssetBundleCustomPackEditorWindow.AddWindow();
    }
    [MenuItem("Build/Asset Bundle/Genarate BuildSettings")]
    static void GenarateBuildSettings()
    {
        GameBuildPipeline_Platform.GenarateBuildSettings();
    }

    [MenuItem("Build/Asset Bundle/Build Use Manual Name")]
    static void TestAssetBundleUsingRestName()
    {
        string outputPath = Application.streamingAssetsPath + "AssetBundle";
        BuildPipeline.BuildAssetBundles(outputPath, BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.StandaloneWindows);
    }

}