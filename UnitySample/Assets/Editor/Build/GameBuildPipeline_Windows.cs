using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;

public class GameBuildPipeline_Windows
{
    private static bool BuildWithAB = false;
    private const string exeName = "/Redfox.exe";

    //call by VisualBuild only
    public static void Build()
    {
        string apkName = GameBuildPipeline_Platform.GetBuildTargetPath(BuildTarget.StandaloneWindows) + exeName;
        string errorMsg = DoBuild(apkName, BuildOptions.None);
        if (!string.IsNullOrEmpty(errorMsg))
        {
            Debug.LogError(errorMsg);
            System.Environment.Exit(1);
        }
    }

    //call by VisualBuild
    public static void BuildWindowsData()
    {
        try
        {
            DoBuildWindowsData();
        }
        catch (System.Exception ex)
        {
            Debug.LogError(ex.ToString());
            System.Environment.Exit(1);
        }
    }

    //开发人员本机生成Windows包
    [MenuItem("Build/Build Windows Exe", false, 100)]
    private static void BuildWindows()
    {
        GameBuildPipeline_Platform.PreBuild(BuildTarget.StandaloneWindows,BuildWithAB);
        DoBuildWindowsData();
        BuildWindowsExe();
    }

    private static void BuildWindowsTag2()
    {
        GameBuildPipeline_Platform.BUILD_TAG = 2;
        BuildWindows();
    }


    private static string DoBuild(string apkName, BuildOptions op)
    {
        if (BuildWithAB)
        {
            GameBuildPipeline_Platform.MoveResourcesAway();
        }

        string[] scenes = GameBuildPipeline_Platform.GetBuildScene(BuildTarget.StandaloneWindows);

        string msg = BuildPipeline.BuildPlayer(scenes, apkName, BuildTarget.StandaloneWindows, op);

        if (BuildWithAB)
        {
            GameBuildPipeline_Platform.MoveResourcesBack();
        }

        //copy data file
        string srcDir = GameBuildPipeline_Platform.GetBuildDataExportPath(BuildTarget.StandaloneWindows);
        string dstDir = GameBuildPipeline_Platform.GetBuildTargetPath(BuildTarget.StandaloneWindows);
        GameBuildPipeline_Platform.DeleteDir(dstDir + "/data");
        GameBuildPipeline_Platform.CopyDir(srcDir, dstDir + "/data");

        return msg;
    }

    [MenuItem("Build/Build Windows/Build VFS", false, 110)]
    private static void BuildWindowsVFS()
    {
        GameBuildPipeline_VFS.BuildVFS(BuildTarget.StandaloneWindows);
    }

    [MenuItem("Build/Build Windows/Build Bundles", false, 120)]
    private static void BuildWindowsBundles()
    {
        GameBuildPipeline_AssetBundle.BuildPlatformAll(BuildTarget.StandaloneWindows);
    }

    [MenuItem("Build/Build Windows/Build IFS", false, 130)]
    private static void BuilWindowIFSPack()
    {
        GameBuildPipeline_Platform.BuildIFSPack(BuildTarget.StandaloneWindows);
    }

    [MenuItem("Build/Build Windows/Build All Data", false, 150)]
    private static void DoBuildWindowsData()
    {
        Debug.Log("BuildWindowsData start----------------");

        //0 clear export data path
        //GameBuildPipeline_Platform.DeleteDir( GameBuildPipeline_Platform.GetBuildDataExportPath(BuildTarget.StandaloneWindows));

        //1 build vfs file
        GameBuildPipeline_VFS.BuildVFS(BuildTarget.StandaloneWindows);

        //2 build asset bundles
        if (BuildWithAB)
        {
            GameBuildPipeline_AssetBundle.BuildPlatformAll(BuildTarget.StandaloneWindows);
        }

        Debug.Log("BuildStandaloneWindowsData finish----------------");
    }
    //开发人员本机生成Windows包
    [MenuItem("Build/Build Windows/Update Exe", false, 180)]
    private static void BuildWindowsExe()
    {
        string dir = GameBuildPipeline_Platform.GetBuildTargetPath(BuildTarget.StandaloneWindows);
        string apkName = dir + exeName;

        GameBuildPipeline_Platform.DeleteDir(dir);

        string errorMsg = DoBuild(apkName, GameBuildPipeline_Platform.GetBuildOptions(BuildTarget.StandaloneWindows));
        if (!string.IsNullOrEmpty(errorMsg))
        {
            Debug.LogError(errorMsg);
        }
    }


    private static string[] GetBuildScenes()
    {
        List<string> names = new List<string>();
        foreach (EditorBuildSettingsScene e in EditorBuildSettings.scenes)
        {
            if (e == null)
            {
                continue;
            }
            if (e.enabled)
            {
                names.Add(e.path);
            }
        }
        return names.ToArray();
    }

    [MenuItem("Build/Build Windows Test", false, 510)]
    private static void BuildWindowsTag1()
    {
        GameBuildPipeline_Platform.BUILD_TAG = 1;
        BuildWindows();
    }
}