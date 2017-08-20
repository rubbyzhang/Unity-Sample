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

public static class ExtractBunildInMenu
{
    //---------------------------------------------------------------------------------------
    static BunildInResourceManager buildInManager = new BunildInResourceManager();

    [MenuItem("Extract Buildin/Extract BuildIn Resource")]
    public static void ExtractInternalResource22()
    {
        buildInManager.CopyShader();

        buildInManager.Init();
    }
    
    [MenuItem("Extract Buildin/Foprce Update BuildIn Resource")]
    public static void ExtractInternalResourceForce()
    {
        buildInManager.Init(true);
    }

    [MenuItem("Extract Buildin/Replace Yaml")]

    static void ReplaceYamlData()
    {
        Object[] objects = Selection.objects;
        List<string> assetPaths = new List<string>();
        foreach (var obj in objects)
        {
            string assetPath = AssetDatabase.GetAssetPath(obj);
            assetPaths.Add(assetPath);
        }

        buildInManager.Replace(assetPaths);
    }

    [MenuItem("Extract Buildin/Pack Bundle")]
    static void PackBundle()
    {
        GameBuildPipeline_AssetBundle.BuildPlatformAll(BuildTarget.StandaloneWindows, BundleType.Character);
    }

    [MenuItem("Extract Buildin/Restore Yaml")]

    static void RestoreYamlData()
    {
        buildInManager.Restore();
    }

    [MenuItem("Extract Buildin/Pack Character")]
    static void PackCharacter()
    {
        buildInManager.CopyShader();

        buildInManager.Init();

        List<string> assetFiles = AssetBundlePackageTool.GetAssetFileList(BundleType.Character);
        buildInManager.Replace(assetFiles);

        AssetDatabase.Refresh();

        GameBuildPipeline_AssetBundle.BuildPlatformAll(BuildTarget.StandaloneWindows, BundleType.Character);
        buildInManager.Restore();

        buildInManager.DeleteShader();
    }

    [MenuItem("Extract Buildin/Copy Shader")]
    static void CopyShader()
    {
        buildInManager.CopyShader();
    }

    [MenuItem("Extract Buildin/Delete Shader")]
    static void DeleteShader()
    {
        buildInManager.DeleteShader();
    }

    [MenuItem("Extract Buildin/Get Dependencies")]
    public static void GetDependencies2()
    {
        Object[] objects = Selection.objects;
        List<string> paths = new List<string>();
        for (int i = 0; i < objects.Length; i++)
        {
            string path = AssetDatabase.GetAssetPath(objects[0]);
            paths.Add(path);
        }
        List<string> dependencies = AssetDatabase.GetDependencies(paths.ToArray(), true).ToList();

        for (int i = 0; i < dependencies.Count; i++)
        {
            Debug.Log("________________________ :" + dependencies[i]);
        }
    }

    [MenuItem("Extract Buildin/Collection Dependencies")]
    public static void CollectionDependencies()
    {
        Object[] objects = Selection.objects;
        Object[] dependencies = EditorUtility.CollectDependencies(objects);

        for (int i = 0; i < dependencies.Length; i++)
        {
            string path = AssetDatabase.GetAssetPath(dependencies[i]);
            Debug.Log("________________________ :" + path);
        }
    }

    [MenuItem("Extract Buildin/Get File Id")]
    static void GetObjectFileID()
    {
        Object[] objects = Selection.objects;
        if (objects.Length == 0)
        {
            return;
        }

        long fileID = GetFileID(objects[0]);
        string path = AssetDatabase.GetAssetPath(objects[0]);
        string GUID = AssetDatabase.AssetPathToGUID(path);
        Debug.Log("Name:" + objects[0].name + ", FileID:" + fileID + ", GUID:" + GUID);
    }

    static void GetObjectFileID(this Object target)
    {
        if (target == null)
        {
            return;
        }

        long fileID = GetFileID(target);
        string path = AssetDatabase.GetAssetPath(target);
        string GUID = AssetDatabase.AssetPathToGUID(path);
        Debug.Log("Name:" + target.name + ", FileID:" + fileID + ", GUID:" + GUID);
    }

    private static PropertyInfo inspectorMode = typeof(SerializedObject).GetProperty("inspectorMode",
        BindingFlags.NonPublic | BindingFlags.Instance);

    static long GetFileID(this Object target)
    {
        SerializedObject serializedObject = new SerializedObject(target);
        inspectorMode.SetValue(serializedObject, InspectorMode.Debug, null);
        SerializedProperty localIdProp = serializedObject.FindProperty("m_LocalIdentfierInFile");
        return localIdProp.longValue;
    }

}