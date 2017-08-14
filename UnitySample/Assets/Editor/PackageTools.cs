using  System.Collections.Generic;
using UnityEditor;
using UnityEngine ;
using System.IO ;

public class PackageTools
{
    //平台
    private static BuildTarget mPlatformTarget = BuildTarget.Android;

    [MenuItem("Bundle Scene/Create  using BuildPlayer")]
    static void CreateWindowsSceneSceneLoader()
    {
        string[] levels = new string[] { "Assets/Scene/SceneA.unity"/*, "Assets/Scene/SceneB.unity"*/ };

        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
        buildPlayerOptions.scenes = levels;
        buildPlayerOptions.locationPathName = "Assets/StreamingAssets/AssetBundle/win_scene";
        buildPlayerOptions.target = BuildTarget.StandaloneWindows;
        buildPlayerOptions.options = BuildOptions.BuildAdditionalStreamedScenes;
        BuildPipeline.BuildPlayer(buildPlayerOptions);
    }

    [MenuItem("Bundle Scene/Create using BuildAssetBundles")]
    static void BuildTestWindowTarget()
    {
        BuildPipeline.BuildAssetBundles("Assets/StreamingAssets/AssetBundle/", BuildAssetBundleOptions.ChunkBasedCompression, BuildTarget.StandaloneWindows);
    }

    //指定目录打包资源
    [MenuItem("AssetBundle/Build Window Target")]
    static void BuildTargetPathWindowAssetBundle()
    {
        //BundlePackageTools.BuildAssetBundle(BundleType.Max, BuildTarget.StandaloneWindows);
    }

    //指定目录打包资源
    [MenuItem("AssetBundle/Build Android Target")]
    static void BuildTargetPathAssetAndroidBundle()
    {
        //BundlePackageTools.BuildAssetBundle(BundleType.Character, BuildTarget.Android, bundlePath, false);
        AssetDatabase.Refresh();
    }

    static void GetNames()
    {
        var names = AssetDatabase.GetAllAssetBundleNames();
        foreach (var name in names)
        {
            Debug.Log("AssetBundle: " + name);
        }
    }

	[MenuItem("AssetBundle/Search Dependencies")]
    static void Search()
	{
	    GameObject[] objs = Selection.gameObjects;
        List<string> objPath = new List<string>();
	    for (int i = 0; i < objs.Length; i++)
	    {
	        string path = AssetDatabase.GetAssetPath(objs[i]);
            objPath.Add(path);
	    }

        string[] paths = AssetDatabase.GetDependencies(objPath.ToArray());
        foreach (string path in paths)
        {
            Debug.Log(path);
        }
    }
}
