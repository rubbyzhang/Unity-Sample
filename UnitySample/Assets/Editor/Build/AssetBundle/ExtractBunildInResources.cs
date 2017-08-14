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
using Object = UnityEngine.Object;


class AssetItemInfo
{
    public string Guid;
    public long FileId;
    public string FileName;
    public Type FileType;

    public AssetItemInfo()
    {
        Guid = "";
        FileId = 0;
        FileName = "";
    }
}

class BuildInResourceManager
{
    Dictionary<long, bool> mCanReplaceAssetDic = new Dictionary<long, bool>();

    Dictionary<long, AssetItemInfo> mSrcAssetFileInfos = new Dictionary<long, AssetItemInfo>();
    Dictionary<long, AssetItemInfo> mReplaceAssetFileInfos = new Dictionary<long, AssetItemInfo>();

    public static List<Type> ConstAssetTypeList =
        new List<Type>
        {
            typeof (Material),
            typeof (Texture2D),
            typeof (AnimationClip),
            typeof (AudioClip),
            typeof (Sprite),
            typeof(Shader),
            typeof(Font),
            typeof (Mesh)
        };

    private string ConstReplaceShaderAssetFolder = "Assets/BuildInResources/Editor/BuildInShader/";

    public void Extract()
    {
        mSrcAssetFileInfos.Clear();
        mReplaceAssetFileInfos.Clear();
        mCanReplaceAssetDic.Clear();

        ExtractInternalResource("Resources/unity_builtin_extra" , "Assets/BuildInResources/Res/");
    }

    private void ExtractInternalResource(string BuildInPath , string outputPath)
    {
        string outputFullPath = AssetBundleUtil.ToFullPath(outputPath);
        if (Directory.Exists(outputFullPath))
        {
            Directory.CreateDirectory(outputFullPath);
        }

        Object[] UnityAssets = AssetDatabase.LoadAllAssetsAtPath(BuildInPath);
        foreach (var asset in UnityAssets)
        {
            string path = AssetDatabase.GetAssetPath(asset);
            Debug.Log("________________________ Path:" + path + ", Name:" + asset.name + ",Type:" + asset.GetType());

            AssetItemInfo srcItem = GetAssetItem(asset);
            if (!mSrcAssetFileInfos.ContainsKey(srcItem.FileId))
            {
                mSrcAssetFileInfos.Add(srcItem.FileId, srcItem);
            }

            if (!mCanReplaceAssetDic.ContainsKey(srcItem.FileId))
            {
                mCanReplaceAssetDic.Add(srcItem.FileId,true);
            }

            string newResAssetPath = ExtractResItem(asset, outputPath);
//
//            if (item.FileType == typeof (Sprite))
//            {
//                SetSpriteImportSetting(outputPath + asset);
//            }
//            else if (item.FileType == typeof(Texture2D))
//            {
//                //todo
//            }

            string newItemAssetPath = string.Empty;
            if (srcItem.FileType == typeof (Sprite) || srcItem.FileType == typeof (Texture2D) || srcItem.FileType == typeof (Material))
            {
                if (!string.IsNullOrEmpty(newResAssetPath))
                {
                    newItemAssetPath = AssetBundleUtil.ToProjectPath(newResAssetPath); ;
                }
            }
            else if (srcItem.FileType == typeof (Shader))
            {
                string str = FindReplaceShader(asset.name);
                if (string.IsNullOrEmpty(str))
                {
                    Debug.LogError("Find Shader Fail:" + asset.name);
                    continue;
                }
                newItemAssetPath = AssetBundleUtil.ToProjectPath(str);
            }

            if (!string.IsNullOrEmpty(newItemAssetPath))
            {
                UnityEngine.Object newObj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(newItemAssetPath);
                AssetItemInfo newitem = GetAssetItem(newObj);
                if (newitem == null)
                {
                    Debug.LogError("Miss new Item, Path:" + newItemAssetPath);
                    continue;
                }

                if (!mReplaceAssetFileInfos.ContainsKey(srcItem.FileId))
                {
                    mReplaceAssetFileInfos.Add(srcItem.FileId, newitem);
                }
            }
        }

        foreach (var assetPairItem in mCanReplaceAssetDic)
        {
            long fileiD = assetPairItem.Key;
            Debug.Log("<color=red>FileId:" + fileiD + "</color>");
            if (mSrcAssetFileInfos.ContainsKey(fileiD))
            {
                Debug.Log("Src guid:" + mSrcAssetFileInfos[fileiD].Guid + ",name:" + mSrcAssetFileInfos[fileiD].FileName);
            }

            if (mReplaceAssetFileInfos.ContainsKey(fileiD))
            {
                Debug.Log("dst guid:" + mReplaceAssetFileInfos[fileiD].Guid + ",name:" + mReplaceAssetFileInfos[fileiD].FileName);
            }
        }
    }


    private AssetItemInfo GetAssetItem(UnityEngine.Object target)
    {
        if (null == target )
        {
            return null ;
        }
        
        AssetItemInfo assetItem = new AssetItemInfo();
        assetItem.FileName = target.name;
        assetItem.Guid = GetGuid(target);
        assetItem.FileId = GetFileID(target);
        assetItem.FileType =  target.GetType();
        return assetItem;
    }

    private string ExtractResItem(Object srcAssetItem , string outputPath)
    {
        if (null == srcAssetItem)
        {
            return string.Empty;
        }

        Type assetType = srcAssetItem.GetType();
        string name = srcAssetItem.name;
        string path = AssetDatabase.GetAssetPath(srcAssetItem);

        if (assetType == typeof(Material))
        {
            string createPath = outputPath  + name + ".mat";
            Material newMat = new Material(srcAssetItem as Material);
            AssetDatabase.CreateAsset(newMat, createPath);

            return createPath;
        }
        else if (assetType == typeof(Texture2D))
        {
            string createPath = outputPath + name + ".png";
            SaveTexture(srcAssetItem as Texture2D, createPath);

            return createPath;
        }
        else if (assetType == typeof(Sprite))
        {
            string createPath = outputPath + name + ".png";
            Texture2D tex = (srcAssetItem as Sprite).texture;
            SaveTexture(tex, createPath);

            return createPath;
        }
        else if (assetType == typeof (Shader))   //直接下载shader 放在Editor下
        {
            return string.Empty;
        }
        else
        {
            Debug.Log("没有提取的类型 ----- Path:" + path + ", Name:" + name + ",Type:" + assetType);
            return string.Empty;
        }

        return string.Empty;
    }

    private void SaveTexture(Texture2D tex, string assetPath)
    {
        if (tex == null)
        {
            return;
        }

        byte[] bytes = tex.GetRawTextureData();   //不可读
        Texture2D newTexture = new Texture2D(tex.width, tex.height, tex.format, tex.mipmapCount > 0);
        newTexture.LoadRawTextureData(bytes);

        newTexture.Apply();
        byte[] pngBytes = newTexture.EncodeToPNG();
        Object.DestroyImmediate(newTexture);
        File.WriteAllBytes(assetPath, pngBytes);
    }

    private List<string> mShaderFileList = new List<string>();

    private string FindReplaceShader(string assetName)
    {
        if (string.IsNullOrEmpty(assetName))
        {
            return string.Empty;
        }

        string shaderFullPath = AssetBundleUtil.ToFullPath(ConstReplaceShaderAssetFolder);
        if (mShaderFileList == null || mShaderFileList.Count == 0)
        {
            mShaderFileList = GetAllTargetFile(shaderFullPath);
        }

        foreach (var shaderPath in mShaderFileList)
        {
            string shadertAssetPath = AssetBundleUtil.ToProjectPath(shaderPath);
            Object shaderObj = AssetDatabase.LoadAssetAtPath<Object>(shadertAssetPath);
            if (shaderObj != null && shaderObj.name== assetName)
            {
                return shaderPath;
            }
        }

        return String.Empty; 
    }

    private List<string> GetAllTargetFile(string rootFolderPath)
    {
        List<string> fileList = new List<string>();
        if (string.IsNullOrEmpty(rootFolderPath))
        {
            return fileList;
        }

        DirectoryInfo folder = new DirectoryInfo(rootFolderPath);
        if (!folder.Exists)
        {
            if (File.Exists(rootFolderPath))
            {
                fileList.Add(rootFolderPath);
            }
            else
            {
                Debug.LogError(" rootFolderPath" + rootFolderPath + "必须为文件夹或者单个有效文件");
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

    private void SetSpriteImportSetting(string assetPath)
    {
        if (string.IsNullOrEmpty(assetPath))
        {
            return;
        }

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


    private static PropertyInfo inspectorMode = typeof (SerializedObject).GetProperty("inspectorMode",
        BindingFlags.NonPublic | BindingFlags.Instance);

    long GetFileID(UnityEngine.Object target)
    {
        SerializedObject serializedObject = new SerializedObject(target);
        inspectorMode.SetValue(serializedObject, InspectorMode.Debug, null);
        SerializedProperty localIdProp = serializedObject.FindProperty("m_LocalIdentfierInFile");
        return localIdProp.longValue;
    }

    string GetGuid(string path)
    {
        if (string.IsNullOrEmpty(path))
        {
            return string.Empty;
        }

        string GUID = AssetDatabase.AssetPathToGUID(path);
        return GUID;
    }

    string GetGuid(UnityEngine.Object target)
    {
        if (null == target)
        {
            return string.Empty;
        }

        string path = AssetDatabase.GetAssetPath(target);
        string GUID = AssetDatabase.AssetPathToGUID(path);
        return GUID;
    }
}

public static class ExtractBunildInResources
{
    //---------------------------------------------------------------------------------------

    [MenuItem("Build/Extract Internal Resource 222")]
    public static void ExtractInternalResource22()
    {
        BuildInResourceManager mgr =new BuildInResourceManager();
        mgr.Extract();
    }

    [MenuItem("Build/Asset Bundle/Get Dependencies")]
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

    [MenuItem("Build/Asset Bundle/Get Dependencies2")]
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

    [MenuItem("Build/Extract Internal Resource")]
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

            if (assetType == typeof (Material))
            {
                string createPath = "Assets/BuildInResources/Res/" + asset.name + ".mat";
                Material newMat = new Material(asset as Material);
                AssetDatabase.CreateAsset(newMat, createPath);
            }
            else if (assetType == typeof (Texture2D))
            {
                string createPath = "Assets/BuildInResources/Res/" + asset.name + ".png";
                SaveTexture(asset as Texture2D, createPath);
            }
            else if (assetType == typeof (Sprite))
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


    [MenuItem("Build/Asset Bundle/Create Material")]
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


    [MenuItem("Build/Get File Id")]
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

    private static PropertyInfo inspectorMode = typeof (SerializedObject).GetProperty("inspectorMode",
        BindingFlags.NonPublic | BindingFlags.Instance);

    static long GetFileID(this Object target)
    {
        SerializedObject serializedObject = new SerializedObject(target);
        inspectorMode.SetValue(serializedObject, InspectorMode.Debug, null);
        SerializedProperty localIdProp = serializedObject.FindProperty("m_LocalIdentfierInFile");
        return localIdProp.longValue;
    }
}