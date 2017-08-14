using UnityEditor; 
using System.IO; 
using System.Collections; 
using UnityEngine; 
using System.Collections.Generic; 

public class GameBuildPipeline_iOS
{
    private static bool BuildWithAB = false;

    private const string appName = "";

    //call by VisualBuild only
    public static void Build()
    {
    }
    
    [MenuItem("Build/Build iOS/AssetBundleDev", false, 220)]
    public static void BuildAssetBundleDev()
    {
        BuildWithAB = true;

        string symbolStr = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS);
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS, symbolStr + ";UsingAssetBundle");

        BuildIOSXcode_Real_Machine();

        BuildWithAB = false;

        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS, symbolStr);
    }

    [MenuItem("Build/Build iOS/update AssetBundleDev", false, 230)]
    public static void UpdateBuildAssetBundleDev()
    {
        BuildWithAB = true;

        string symbolStr = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android);
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, symbolStr + ";UsingAssetBundle");

        BuildIOSXcode();

        BuildWithAB = false;

        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, symbolStr);
    }

    //call by VisualBuild
    public static void BuildiOSData()
    {
    }
    //开发人员本地生成xcode project
    [MenuItem("Build/Build Data To Xcode Real Machine", false, 208)]
    private static void BuildIOSXcode_Real_Machine()
    {
        GameBuildPipeline_Platform.PreBuild(BuildTarget.iOS, BuildWithAB);
        DoBuildIOSData();
        PlayerSettings.iOS.sdkVersion = UnityEditor.iOSSdkVersion.DeviceSDK;
        BuildIOSXcode();
    }
    private static void BuildiOSTag1()
    {
        GameBuildPipeline_Platform.BUILD_TAG = 1;
        BuildIOSXcode_Real_Machine();
    }
    private static void BuildiOSTag2()
    {
        GameBuildPipeline_Platform.BUILD_TAG = 2;
        BuildIOSXcode_Real_Machine();
    }
    //开发人员本地生成xcode project
    [MenuItem("Build/Build Data To Xcode Simulator", false, 209)]
    private static void BuildIOSXcode_Simulator()
    {
        DoBuildIOSData();
        PlayerSettings.iOS.sdkVersion = UnityEditor.iOSSdkVersion.SimulatorSDK;
        BuildIOSXcode();
    }


    [MenuItem("Build/Build iOS/Build VFS", false, 210)]
    private static void DoBuildIOSDataVFS()
    {
        GameBuildPipeline_VFS.BuildVFS(BuildTarget.iOS);
        GameBuildPipeline_Platform.BuildIFSPack(BuildTarget.iOS);
    }

    [MenuItem("Build/Build iOS/Build Bunddle", false, 211)]
    static void Build_IOS_Bundle()
    {
        GameBuildPipeline_AssetBundle.BuildPlatformAll(BuildTarget.iOS);
    }

    [MenuItem("Build/Build iOS/Build IFS", false, 212)]
    private static void DoBuildIOSDataIFS()
    {
        GameBuildPipeline_Platform.BuildIFSPack(BuildTarget.iOS);
    }

    [MenuItem("Build/Build iOS/Build All Data", false, 213)]
    private static void DoBuildIOSData()
    {
        Debug.Log("BuildIOSData start----------------");
        //0 clear export data path
        //GameBuildPipeline_Platform.DeleteDir( GameBuildPipeline_Platform.GetBuildDataExportPath(BuildTarget.iOS));

        //1 build vfs file
        GameBuildPipeline_VFS.BuildVFS(BuildTarget.iOS);

        //2 build asset bundles
        if (BuildWithAB)
        {
            GameBuildPipeline_AssetBundle.BuildPlatformAll(BuildTarget.iOS);
        }

        //3 create and copy data.ifs
        GameBuildPipeline_Platform.BuildIFSPack(BuildTarget.iOS);
        Debug.Log("BuildIOSData finish----------------");
    }

    [MenuItem("Build/Build iOS/Build Xcode Proj", false, 214)]
    private static void BuildIOSXcode()
    {
        //clear output dir
        string dir = GameBuildPipeline_Platform.GetBuildTargetPath(BuildTarget.iOS);
        string apkName = dir + appName;
        GameBuildPipeline_Platform.DeleteDir(dir);

        string errorMsg = DoBuild(apkName, GameBuildPipeline_Platform.GetBuildOptions(BuildTarget.iOS));
        if (!string.IsNullOrEmpty(errorMsg))
        {
            Debug.LogError(errorMsg);
        }
    }

    private static string DoBuild(string apkName, BuildOptions op)
    {
        string srcDir = GameBuildPipeline_Platform.GetBuildDataExportPath(BuildTarget.iOS);
        string dstDir = GameBuildPipeline_Platform.GetBuildTargetPath(BuildTarget.iOS);

        if (BuildWithAB)
        {
            GameBuildPipeline_Platform.MoveResourcesAway();
        }

        SetIOSConfig();

        //string[] scenes = GameBuildPipeline_Platform.GetBuildScene(BuildTarget.iOS);
        string[] scenes;
        if (BuildWithAB)
        {
            scenes = new string[]
            {
                "Assets/Scenes/Update.unity" ,
                "Assets/Scenes/Login.unity" ,
            };
        }
        else
        {
            scenes = GameBuildPipeline_Platform.GetBuildScene(BuildTarget.iOS);
        }

        //string[] scenes = {"Assets/Scenes/Scene_Game.unity"};
        string msg = BuildPipeline.BuildPlayer(scenes, apkName, BuildTarget.iOS, op);

        if (BuildWithAB)
        {
            GameBuildPipeline_Platform.MoveResourcesBack();
        }
        return msg;
    }

    private static void SetIOSConfig()
    {
        PlayerSettings.iOS.targetOSVersion = iOSTargetOSVersion.iOS_8_0;
    }
    //     private static string[] GetBuildScenes()
    //     {
    //         List<string> names = new List<string>();
    //         foreach (EditorBuildSettingsScene e in EditorBuildSettings.scenes)
    //         {
    //             if (e == null)
    //             {
    //                 continue;
    //             }
    //             if (e.enabled)
    //             {
    //                 names.Add(e.path);
    //             }
    //         }
    //         return names.ToArray();
    //     }

} 
