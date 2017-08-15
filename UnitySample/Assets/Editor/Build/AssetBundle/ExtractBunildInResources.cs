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

public static class ExtractBunildInResources
{
    //---------------------------------------------------------------------------------------
    static BuildInResourceManager buildInManager = new BuildInResourceManager();

    [MenuItem("Extract Buildin/Extract BuildIn Resource")]
    public static void ExtractInternalResource22()
    {
        buildInManager.Extract();
    }


    [MenuItem("Extract Buildin/Foprce Update BuildIn Resource")]
    public static void ExtractInternalResourceForce()
    {
        buildInManager.Extract(true);
    }

    [MenuItem("Extract Buildin/Replace Yaml")]

    static void ReplaceYamlData()
    {
        Object[] objects = Selection.objects;
        if (objects.Length == 0)
        {
            return;
        }

        Object selectObj = objects[0];
        string assetPath = AssetDatabase.GetAssetPath(selectObj);
        buildInManager.Extract();
        buildInManager.Replace(assetPath);
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

        //     List<string> dependencies = GetDependencies(paths, true);


        List<string> dependencies = AssetDatabase.GetDependencies(paths.ToArray(), true).ToList();

        for (int i = 0; i < dependencies.Count; i++)
        {
            Debug.Log("________________________ :" + dependencies[i]);
        }

        //        WriteMdFile(dependencies.Distinct().ToList());
    }

    [MenuItem("Extract Buildin/Get Dependencies2")]
    public static void GetDependencies3()
    {
        Object[] objects = Selection.objects;
        Object[] dependenciesObjects = EditorUtility.CollectDependencies(objects);

        for (int i = 0; i < dependenciesObjects.Length; i++)
        {
            string path = AssetDatabase.GetAssetPath(dependenciesObjects[i]);
            Debug.Log("________________________ :" + path);
        }
    }

    private static List<string> GetDependencies(List<string> projectPath, bool isAll = true)
    {
        List<string> paths = new List<string>();
        if (projectPath == null || projectPath.Count == 0)
        {
            return paths;
        }

        string[] dependencies = AssetDatabase.GetDependencies(projectPath.ToArray(), false);

        for (int i = 0; i < dependencies.Length; ++i)
        {
            paths.Add(dependencies[i]);
            Debug.Log("<color=red> Direct dependence Path:" + dependencies[i] + "</color>");
        }

        if (isAll)
        {
            List<string> subPath = new List<string>();
            for (int i = 0; i < dependencies.Length; ++i)
            {
                string assetPath = dependencies[i];
                string lowerAssetPath = assetPath.ToLower();

                if (lowerAssetPath.EndsWith(".mat")
                    || lowerAssetPath.EndsWith(".prefab")
                    || lowerAssetPath.EndsWith(".controller")
                    || lowerAssetPath.EndsWith(".overridecontroller")
                    )
                {
                    subPath.Add(assetPath);
                }
            }

            if (subPath.Count > 0)
            {
                List<string> subDependencies = GetDependencies(subPath, true);
                paths.AddRange(subDependencies);
                for (int i = 0; i < subDependencies.Count; i++)
                {
                    Debug.Log("________________________ :" + subDependencies[i]);
                }
            }
        }

        paths = paths.Distinct().ToList();
        return paths;
    }

    public static List<Type> assetTypeList =
        new List<Type>
        {
            typeof (Material),
            typeof (Texture2D),
            typeof (AnimationClip),
            typeof (AudioClip),
            typeof (Sprite),
//            typeof(Shader),
//            typeof(Font),
            typeof (Mesh)
        };

//    [MenuItem("Extract Buildin/Extract Internal Resource 1")]
    public static void ExtractInternalResource()
    {
        Object[] UnityAssets = AssetDatabase.LoadAllAssetsAtPath("Resources/unity_builtin_extra");
        foreach (var asset in UnityAssets)
        {
            string path = AssetDatabase.GetAssetPath(asset);
            Type assetType = asset.GetType();


            if (assetTypeList.Contains(assetType))
            {
                Debug.Log("________________________ Path:" + path + ", Name:" + asset.name + ",Type:" + asset.GetType());
            }

            GetObjectFileID(asset);

            if (assetType == typeof(Material))
            {
                string createPath = "Assets/BuildInResources/Res/" + asset.name + ".mat";
                Material newMat = new Material(asset as Material);
                AssetDatabase.CreateAsset(newMat, createPath);
            }
            else if (assetType == typeof(Texture2D))
            {
                string createPath = "Assets/BuildInResources/Res/" + asset.name + ".png";
                SaveTexture(asset as Texture2D, createPath);
            }
            else if (assetType == typeof(Sprite))
            {
                string createPath = "Assets/BuildInResources/Res/" + asset.name + ".png";
                Texture2D tex = (asset as Sprite).texture;
                SaveTexture(tex, createPath);
            }
            else
            {
                continue;
            }
        }


        // 修改导入配置
        RefershBuildinSpriteAsset("Assets/BuildInResources/Res/");
    }

    private static void SaveTexture(Texture2D tex, string assetPath)
    {
        if (tex == null)
        {
            return;
        }

        byte[] bytes = tex.GetRawTextureData();
        Texture2D newTexture = new Texture2D(tex.width, tex.height, tex.format, tex.mipmapCount > 0);
        newTexture.LoadRawTextureData(bytes);

        //        for (int y = 0; y < newTexture.height; y++)   // 内置资源不可读
        //        {
        //            for (int x = 0; x < newTexture.width; x++)
        //            {
        //                Color clr = tex.GetPixel(x , y);
        //                newTexture.SetPixel(x, y, clr);
        //            }
        //        }

        newTexture.Apply();
        byte[] pngBytes = newTexture.EncodeToPNG();
        Object.DestroyImmediate(newTexture);
        File.WriteAllBytes(assetPath, pngBytes);
    }

    private static void RefershBuildinSpriteAsset(string folderPath)
    {
        AssetDatabase.Refresh();

        string fullPath = AssetBundleUtil.ToFullPath(folderPath);
        if (!Directory.Exists(fullPath))
        {
            return;
        }

        DirectoryInfo direction = new DirectoryInfo(fullPath);
        FileInfo[] files = direction.GetFiles("*", SearchOption.AllDirectories);

        List<string> spriteFiles = new List<string>();
        for (int i = 0; i < files.Length; i++)
        {
            if (files[i].Name.EndsWith(".png"))
            {
                string path = folderPath + "/" + files[i].Name;
                spriteFiles.Add(path);
            }
        }

        foreach (var assetPath in spriteFiles)
        {
            TextureImporter importer = AssetImporter.GetAtPath(assetPath) as TextureImporter;
            if (importer != null)
            {
                importer.textureType = TextureImporterType.Sprite;
                importer.wrapMode = TextureWrapMode.Clamp;
                importer.mipmapEnabled = false;
                importer.spriteImportMode = SpriteImportMode.Single;
                importer.filterMode = FilterMode.Bilinear;
                importer.maxTextureSize = 1024;

                if (importer.DoesSourceTextureHaveAlpha())
                {
                    importer.alphaIsTransparency = true;
                    TextureImporterPlatformSettings androidSetting = new TextureImporterPlatformSettings();
                    androidSetting.name = "Android";
                    androidSetting.maxTextureSize = 1024;
                    androidSetting.format = TextureImporterFormat.ETC2_RGBA8;
                    androidSetting.overridden = true;
                    TextureImporterPlatformSettings iosSetting = new TextureImporterPlatformSettings();
                    iosSetting.name = "iPhone";
                    iosSetting.maxTextureSize = 1024;
                    iosSetting.format = TextureImporterFormat.ASTC_RGBA_4x4;
                    iosSetting.overridden = true;
                    importer.SetPlatformTextureSettings(iosSetting);
                    importer.SetPlatformTextureSettings(androidSetting);
                }
                else
                {
                    TextureImporterPlatformSettings androidSetting = new TextureImporterPlatformSettings();
                    androidSetting.name = "Android";
                    androidSetting.maxTextureSize = 1024;
                    androidSetting.format = TextureImporterFormat.ETC2_RGB4;
                    androidSetting.overridden = true;

                    TextureImporterPlatformSettings iosSetting = new TextureImporterPlatformSettings();
                    iosSetting.name = "iPhone";
                    iosSetting.maxTextureSize = 1024;
                    iosSetting.format = TextureImporterFormat.ASTC_RGB_4x4;
                    iosSetting.overridden = true;
                    importer.SetPlatformTextureSettings(iosSetting);
                    importer.SetPlatformTextureSettings(androidSetting);
                }
                importer.SaveAndReimport();
            }
        }
    }


//    [MenuItem("Extract Buildin/Create Material Test")]
    static void CreateMaterial()
    {
        // Create a simple material asset

        Material material = new Material(Shader.Find("Specular"));
        AssetDatabase.CreateAsset(material, "Assets/BuildInRes/MyMaterial.mat");

        // Add an animation clip to it
        AnimationClip animationClip = new AnimationClip();
        animationClip.name = "My Clip";
        AssetDatabase.AddObjectToAsset(animationClip, material);

        // Reimport the asset after adding an object.
        // Otherwise the change only shows up when saving the project
        AssetDatabase.ImportAsset(AssetDatabase.GetAssetPath(animationClip));

        // Print the path of the created asset
        Debug.Log(AssetDatabase.GetAssetPath(material));
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

    [MenuItem("Extract Buildin/ReadYamlData")]

    static void ReadYamlData()
    {
        Object[] objects = Selection.objects;
        if (objects.Length == 0)
        {
            return;
        }

        Object selectObj = objects[0];

        string buildinGUid = "0000000000000000f000000000000000";

        string assetPath = AssetDatabase.GetAssetPath(selectObj);
        string fullPath = AssetBundleUtil.ToFullPath(assetPath);
        string yamlText = System.IO.File.ReadAllText(fullPath);
        Debug.Log(yamlText);
        List<int> indexPos = new List<int>();


        string regionStr = @"{fileID: (\d+), guid: ([A-Za-z0-9]+), type: (\d+)}";
        Regex mConstSpriteTagRegex = new Regex(regionStr, RegexOptions.Singleline);

        foreach (Match match in mConstSpriteTagRegex.Matches(yamlText))
        {
            Debug.Log(match.Groups.Count);
            Debug.Log(match.Index);

            long fileId = long.Parse(match.Groups[1].Value);
            string guid = match.Groups[2].Value;
            int type = int.Parse(match.Groups[3].Value);
            Debug.Log("______Fileid:" + fileId + ",Guid:" + guid + ",type:" + type);

//            string newStr = string.Format("fileID: {0:D}, guid: {1}, type: {2:D}" , fileId+1, guid,type+1);
//            newStr = "{"  + newStr + "}";

//            yamlText = yamlText.Replace(match.Groups[0].Value, newStr);
        }
//        Debug.Log(yamlText);
//        File.WriteAllText(fullPath, yamlText);
    }
}