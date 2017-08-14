using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;

/*
从VisualBuild调用C#代码仅有2个接口
调用接口时，如果不传version string参数，和以前一致。传入参数则生成的apk和data.ifs带有版本号。

//build apk
GameBuildPipeline_Android.Build()

 //打包data目录生成data.ifs并置入apk包
GameBuildPipeline_Android.BuildAndroidData()
*/

public class GameBuildPipeline_Android
{
    //是否打包AB
    private static bool BuildWithAB = false;

    private const BuildOptions BuildOpNone = BuildOptions.None;
    private const BuildOptions BuildOpDevelop = BuildOptions.Development | BuildOptions.ConnectWithProfiler;

    private static string apkName = "/Redfox.apk";

    //---------------------------------------------------------
    //开发人员本机build data.ifs包之后，再build apk包
    [MenuItem("Build/Build Android APK", false, 10)]
    private static void BuildAndroid()
    {
        GameBuildPipeline_Platform.PreBuild(BuildTarget.Android, BuildWithAB);

        DoBuildAndroidData();

        DoBuild(GameBuildPipeline_Platform.GetBuildTargetPath(BuildTarget.Android) + apkName, GameBuildPipeline_Platform.GetBuildOptions(BuildTarget.Android));
    }

    [MenuItem("Build/Build Android/Asset Bundle Dev", false, 80)]
    public static void BuildAssetBundleDev()
    {
        GameBuildPipeline_Platform.StartTimeRecorder("BuildAssetBundleDev");

        if (BuildTarget.Android != EditorUserBuildSettings.activeBuildTarget)
        {
            GameBuildPipeline_Platform.SetCacheServer(true, "10.8.21.74");
            //EditorUserBuildSettings.SwitchActiveBuildTarget(BuildPipeline.GetBuildTargetGroup(BuildTarget.Android), BuildTarget.Android);
        }

        BuildWithAB = true;

        string symbolStr = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android);
        string newSymbol = symbolStr + ";UsingAssetBundle";

        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, newSymbol);

        GameBuildPipeline_Platform.SetCacheServer(false);
        BuildAndroid();

        BuildWithAB = false;
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, symbolStr);
        GameBuildPipeline_Platform.SetCacheServer(true, "10.8.21.74");

        GameBuildPipeline_Platform.StopTimeRecorder("BuildAssetBundleDev");
    }

    [MenuItem("Build/Build Android/Update AssetBundleDev", false, 90)]
    public static void UpdateBuildAssetBundleDev()
    {
        BuildWithAB = true;
        string symbolStr = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android);
        string newSymbol = symbolStr + ";UsingAssetBundle";

        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, newSymbol);

        BuildAPKDevelopEdition();

        BuildWithAB = false;
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, symbolStr);
    }

    [MenuItem("Build/Build Android BattleTest", false, 500)]
    private static void BuildAndroidTag2()
    {
        GameBuildPipeline_Platform.BUILD_TAG = 2;
        BuildAndroid();
    }

    [MenuItem("Build/Build Android BattleTest Debug", false, 501)]
    private static void BuildAndroidTag3()
    {
        GameBuildPipeline_Platform.BUILD_TAG = 3;
        BuildAndroid();
    }

    private static void BuildAndroidTag1()
    {
        GameBuildPipeline_Platform.BUILD_TAG = 1;
        BuildAndroid();
    }

    //打包生成VFS文件并置入apk包
    [MenuItem("Build/Build Android/Update Lua", false, 50)]
    private static void BuildAndroidVFS()
    {
        GameBuildPipeline_VFS.BuildVFS(BuildTarget.Android);
        GameBuildPipeline_Platform.BuildIFSPack(BuildTarget.Android);
        //build apk
        BuildAPKDevelopEdition();
    }

    //打包AssetBundles并置入apk包
    [MenuItem("Build/Build Android/Update AssetBundle", false, 60)]
    private static void BuildAndroidBundles()
    {
        GameBuildPipeline_AssetBundle.BuildPlatformAll(BuildTarget.Android);
        GameBuildPipeline_Platform.BuildIFSPack(BuildTarget.Android);
        //build apk
        BuildAPKDevelopEdition();
    }

    //开发人员本机只build apk包
    private static void BuildAndroidApk()
    {
        DoBuild(GameBuildPipeline_Platform.GetBuildTargetPath(BuildTarget.Android) + apkName, BuildOpDevelop);
    }

    //开发人员本机生成develop版apk包
    private static void BuildAndroidDevelopEdition()
    {
        DoBuildAndroidData();
        BuildAPKDevelopEdition();
    }
    private static void BuildCSharpProject()
    {
        EditorApplication.ExecuteMenuItem("Assets/Open C# Project");
    }

    //开发人员本机生成develop版apk包
    [MenuItem("Build/Build Android/Update Apk", false, 45)]
    public static void BuildAPKDevelopEdition()
    {
        string packageName = GameBuildPipeline_Platform.GetBuildTargetPath(BuildTarget.Android) + apkName;
        string errorMsg = DoBuild(packageName, BuildOpDevelop);

        //if (string.IsNullOrEmpty(errorMsg))
        //{
        //    InstallApk(packageName);
        //}
    }
    //-----------------------------------------------------------------------------
    [MenuItem("Build/Build Android/Build All Data", false, 40)]
    private static void DoBuildAndroidData()
    {
        GameBuildPipeline_Platform.StartTimeRecorder("DoBuildAndroidData");

        //0 clear 
        //GameBuildPipeline_Platform.DeleteDir(GameBuildPipeline_Platform.GetBuildDataExportPath(BuildTarget.Android));

        //1 build vfs file
        GameBuildPipeline_VFS.BuildVFS(BuildTarget.Android);

        //2 build asset bundles
        if (BuildWithAB)
        {
            GameBuildPipeline_AssetBundle.BuildPlatformAll(BuildTarget.Android);
        }
        
        //3 create and copy data.ifs
        GameBuildPipeline_Platform.BuildIFSPack(BuildTarget.Android);

        GameBuildPipeline_Platform.StopTimeRecorder("DoBuildAndroidData");
    }

    [MenuItem("Build/Build Android/Genarate Prepare Data", false, 15)]
    private static void BuilAndroidPrepareData()
    {
        GameBuildPipeline_Platform.PreBuild(BuildTarget.Android);
    }

    [MenuItem("Build/Build Android/Build VFS", false, 20)]
    private static void BuilAndroidVFSPack()
    {
        GameBuildPipeline_VFS.BuildVFS(BuildTarget.Android);
    }

    [MenuItem("Build/Build Android/Build Bunddle", false, 25)]
    public static void Build_Android_Bundle()
    {
        GameBuildPipeline_AssetBundle.BuildPlatformAll(BuildTarget.Android);
    }

    [MenuItem("Build/Build Android/Build IFS", false, 30)]
    private static void BuilAndroidIFSPack()
    {
        GameBuildPipeline_Platform.BuildIFSPack(BuildTarget.Android);
    }

    [MenuItem("Build/Build Android/Remove Bundle", false, 70)]
    private static void RemoveAllBundle()
    {
        GameBuildPipeline_AssetBundle.RemoveAllBundleAsset(BuildTarget.Android);
    }

    [MenuItem("Build/Build Android/Move Resources Away", false, 100)]
    private static void RemoveUnuseResources()
    {
        GameBuildPipeline_Platform.MoveResourcesAway();
    }

    [MenuItem("Build/Build Android/Move Resources Back", false, 110)]
    private static void MoveResourcesBack()
    {
        GameBuildPipeline_Platform.MoveResourcesBack();
    }

    //call by VisualBuild only
    public static void Build()
    {
        string apkPath = GameBuildPipeline_Platform.GetBuildTargetPath(BuildTarget.Android) + apkName;
        string errorMsg = DoBuild(apkPath, GameBuildPipeline_Platform.GetBuildOptions(BuildTarget.Android));
        if (!string.IsNullOrEmpty(errorMsg))
        {
            Debug.LogError(errorMsg);
            System.Environment.Exit(1);
        }

        //rename apk with version info and create json config
        string version = GameBuildPipeline_Platform.GetCommandLineVersion();
        if (version.Length > 0)
        {
            bool ok = GameBuildPipeline_Platform.CreateApkVersion(apkPath, version);
            if (!ok)
            {
                System.Environment.Exit(1);
            }
        }
    }

    //call by VisualBuild only
    //打包data目录生成data.ifs并置入apk包
    public static void BuildAndroidData()
    {
        Debug.Log("BuildAndroidData start----------------");

        bool ok = true;
        try
        {
            DoBuildAndroidData();

            //rename data.ifs with version and create .json file
            string version = GameBuildPipeline_Platform.GetCommandLineVersion();
            if (version.Length > 0)
            {
                ok = GameBuildPipeline_Platform.CreateDataIfsVersion(BuildTarget.Android, version);
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError(ex.ToString());
            ok = false;
        }

        if (!ok)
        {
            System.Environment.Exit(1);
        }

        Debug.Log("BuildAndroidData finish----------------");
    }

    private static void InstallApk(string packageName)
    {
        System.Diagnostics.Process packager = new System.Diagnostics.Process();
        packager.StartInfo.FileName = Path.Combine(Directory.GetCurrentDirectory(), packageName);
        packager.StartInfo.CreateNoWindow = true;
        packager.StartInfo.UseShellExecute = true;
        packager.Start();

        Debug.Log("InstallApk " + packageName);
    }

    private static void ApplyKeystore()
    {
        PlayerSettings.Android.keystoreName = Path.Combine(Application.dataPath, "../redfox.keystore");
        PlayerSettings.Android.keystorePass = "redfox";
        PlayerSettings.Android.keyaliasName = "redfox";
        PlayerSettings.Android.keyaliasPass = "redfox";
    }

    private static string DoBuild(string apkName, BuildOptions op)
    {
        GameBuildPipeline_Platform.StartTimeRecorder("Build Player");

        if (BuildWithAB)
        {
            GameBuildPipeline_Platform.StartTimeRecorder("MoveResourcesAway");
            GameBuildPipeline_Platform.MoveResourcesAway();
            GameBuildPipeline_Platform.StopTimeRecorder("MoveResourcesAway");
        }

        ApplyKeystore();

        string apkPath = apkName.Substring(0, apkName.LastIndexOf("/"));
        if (!Directory.Exists(apkPath))
        {
            Directory.CreateDirectory(apkPath);
        }

        string[] sceneName;
        if (BuildWithAB)
        {
            sceneName = new string[]
            {
                "Assets/Scenes/Update.unity" ,
                //"Assets/Scenes/Login.unity" ,
            };
        }
        else
        {
            sceneName = GameBuildPipeline_Platform.GetBuildScene(BuildTarget.Android);
        }

        string msg = BuildPipeline.BuildPlayer(sceneName, apkName, BuildTarget.Android, op);

        if (BuildWithAB)
        {
            GameBuildPipeline_Platform.StartTimeRecorder("MoveResourcesBack");
            GameBuildPipeline_Platform.MoveResourcesBack();
            GameBuildPipeline_Platform.StopTimeRecorder("MoveResourcesBack");
        }

        GameBuildPipeline_Platform.StopTimeRecorder("Build Player");

        return msg;
    }

    //     private static string[] GetBuildScenes() {
    //         List<string> names = new List<string>();
    //         foreach (EditorBuildSettingsScene e in EditorBuildSettings.scenes) {
    //             if (e == null) {
    //                 continue;
    //             }
    //             if (e.enabled) {
    //                 names.Add(e.path);
    //             }
    //         }
    //         return names.ToArray();
    //     }

    ////call by Visual Build Only //改为build 和 build data 时候是否传version string来区分
    //private static void CreateAndroidIfsVersion()
    //{
    //    string version = GameBuildPipeline_Platform.GetCommandLineVersion();
    //    if (version.Length <= 0)
    //    {
    //        System.Environment.Exit(1);
    //        return;
    //    }

    //    GameBuildPipeline_Platform.CreateIfsVersion(BuildTarget.Android, version);
    //}
}