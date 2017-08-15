using System;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using AssetBundles;
using JetBrains.Annotations;
using UnityEngine.AI;
using UnityEngine.SceneManagement;
using Object = UnityEngine.Object;


class AssetItemInfo
{
    public string Guid;
    public long FileId;
    public string FileName;
    public Type FileType;
    public string AssetPath; 

    public AssetItemInfo()
    {
        Guid = "";
        FileId = 0;
        FileName = "";
    }
}

class BuildInResourceManager
{
    private List<string> mSrcGuids = new List<string>(); 
    Dictionary<long, AssetItemInfo> mSrcAssetFileInfos = new Dictionary<long, AssetItemInfo>();
    Dictionary<long, AssetItemInfo> mReplaceAssetFileInfos = new Dictionary<long, AssetItemInfo>();

    private bool IsInit = false;

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

    private readonly string ConstReplaceShaderAssetFolder = "Assets/BuildInResources/Editor/BuildInShader/";

    private readonly string ConstReplaceResRootFolder = "Assets/BuildInResources/Res/";
    private readonly string ConstReplaceMaterialFolder =  "Assets/BuildInResources/Res/Material/";
    private readonly string ConstReplaceMeshFolder =  "Assets/BuildInResources/Res/Mesh/";
    private readonly string ConstReplaceTextureFolder = "Assets/BuildInResources/Res/Texture/";

    private readonly string ConstSrcBuildinResFolder1 = "Resources/unity_builtin_extra";
    private readonly  string ConstSrcBuildinResFolder2 = "Library/unity default resources";

    /// <summary>
    /// 替换复合类型文件中内置资源
    /// </summary>
    /// <param name="assetPath"></param>
    public void Replace(string assetPath)
    {
        if (string.IsNullOrEmpty(assetPath))
        {
            Debug.LogError("Replace Error: input assetPath is invalid");
            return;
        }

        string fullPath = AssetBundleUtil.ToFullPath(assetPath);
        string yamlText = File.ReadAllText(fullPath);

//        Debug.Log(yamlText);

        if (yamlText.Length == 0)
        {
            return;
        }

        //非复合资源
        if (!yamlText.Contains("YAML"))
        {
            return;
        }

        bool isContainReplaceContent = false;
        foreach (var guid in mSrcGuids)
        {
            if (yamlText.Contains(guid))
            {
                isContainReplaceContent = true;
                break;
            }
        }

        //不包含需要替换的内容
        if (!isContainReplaceContent)
        {
            return;
        }

        string matchRegex = @"{fileID: (\d+), guid: ([A-Za-z0-9]+), type: (\d+)}";
        Regex mConstSpriteTagRegex = new Regex(matchRegex, RegexOptions.Singleline);

        MatchCollection matchCollection = mConstSpriteTagRegex.Matches(yamlText);
        if (matchCollection.Count == 0)
        {
            return;
        }

        bool contentIsChanged = false;
        foreach (Match match in matchCollection)
        {
            if (match.Groups.Count != 4)
            {
                Debug.LogError("Match Miss, Group is ledd 4,Index:" + match.Index);
                continue;
            }

            long fileId = long.Parse(match.Groups[1].Value);
            string guid = match.Groups[2].Value;
            int type = int.Parse(match.Groups[3].Value);

            Debug.Log("Find Conetent: Fileid:" + fileId + ",Guid:" + guid + ",type:" + type);
            if (!mSrcGuids.Contains(guid))
            {
                continue;
            }

            string newContent = GenerateNewDescInfo(fileId, guid);
            if (string.IsNullOrEmpty(newContent))
            {
                continue;
            }
            Debug.Log("New Conetent: Fileid:" + newContent);
            yamlText = yamlText.Replace(match.Groups[0].Value, newContent);
            contentIsChanged = true;
        }

        if (contentIsChanged)
        {
            Debug.Log("<color=red> Replace YAML Data:" + assetPath + "</color>");

//            Debug.Log(yamlText);
            File.WriteAllText(fullPath, yamlText);
        }
    }

    private string GenerateNewDescInfo(long fileid , string guid)
    {
        if (!mSrcAssetFileInfos.ContainsKey(fileid))
        {
            Debug.LogError("GenerateNewDescInfo Error: 内置文件中不存在该ID" + fileid);
            return string.Empty;
        }

        if (!mReplaceAssetFileInfos.ContainsKey(fileid))
        {
            Debug.LogError("GenerateNewDescInfo Error: 找不到替换文件, ID:" + fileid);
            return string.Empty;
        }

        AssetItemInfo srcItem = mSrcAssetFileInfos[fileid];
        AssetItemInfo dstItem = mReplaceAssetFileInfos[fileid];

        if (srcItem.FileId != fileid || srcItem.Guid != guid)
        {
            Debug.LogError("GenerateNewDescInfo Error: 与内置文件信息不匹配" + fileid);
            return string.Empty;
        }

        //TODO 基本类型：Mesh，Texture，AudioClip，Anim等不会引用其他资源的类型  
        //TODO 复合类型：能引用其他资源的类型，有4种：*.unity，*.prefab，*.material，*.asset。
        //TODO 0代表Unity内置资源，2代表复合类型的外部资源，3代表了基础类型的外部资源

        int assetType = 0;
        string dstAssetPath = dstItem.AssetPath.ToLower();
        if (dstAssetPath.EndsWith(".unity") || dstAssetPath.EndsWith(".mat") || dstAssetPath.EndsWith(".asset") ||
            dstAssetPath.EndsWith(".prefab"))
        {
            assetType = 2;
        }
        else
        {
            assetType = 3;
        }

        long tempFileid = dstItem.FileId;   //FBX特色处理
        if (dstAssetPath.EndsWith(".fbx"))
        {
            tempFileid = 4300000;
        }

        string newStr = string.Format("fileID: {0:D}, guid: {1}, type: {2:D}", tempFileid, dstItem.Guid, assetType);
        newStr = "{" + newStr + "}";

        return newStr;
    }

    public void Extract(bool ForceUpdate = false )
    {
        if (IsInit && !ForceUpdate)
        {
            return;
        }

        mSrcGuids.Clear();
        mSrcAssetFileInfos.Clear();
        mReplaceAssetFileInfos.Clear();

        CreateFolder(ConstReplaceResRootFolder);
        CreateFolder(ConstReplaceMaterialFolder);
        CreateFolder(ConstReplaceMeshFolder);
        CreateFolder(ConstReplaceTextureFolder);

        ExtractInternalResource(ConstSrcBuildinResFolder1, ConstReplaceResRootFolder, ForceUpdate);
        ExtractInternalResource(ConstSrcBuildinResFolder2, ConstReplaceResRootFolder,ForceUpdate);
        IsInit = true;
    }

    private void ExtractInternalResource(string BuildInPath, string outputPath , bool forceUpdate = false)
    {
        Object[] UnityAssets = AssetDatabase.LoadAllAssetsAtPath(BuildInPath);
        foreach (var asset in UnityAssets)
        {
            string path = AssetDatabase.GetAssetPath(asset);
//            Debug.Log("________________________ Path:" + path + ", Name:" + asset.name + ",Type:" + asset.GetType());

            AssetItemInfo srcItem = GetAssetItem(asset);
            if (!mSrcAssetFileInfos.ContainsKey(srcItem.FileId))
            {
                mSrcAssetFileInfos.Add(srcItem.FileId, srcItem);
            }

            if (!mSrcGuids.Contains(srcItem.Guid))
            {
                mSrcGuids.Add(srcItem.Guid);
            }

            // 提取数据
            string newResAssetPath = ExtractResItem(asset, forceUpdate);

            //修改图片格式 
            if (srcItem.FileType == typeof (Sprite))
            {
                SetTextureImportSetting(newResAssetPath, true); 
            }
            else if (srcItem.FileType == typeof(Texture2D))
            {
                SetTextureImportSetting(newResAssetPath, false);
            }

            //记录 用于替换的资源数据
            string newItemAssetPath = string.Empty;
            if (srcItem.FileType == typeof(Sprite) || srcItem.FileType == typeof(Texture2D) || srcItem.FileType == typeof(Material))
            {
                if (!string.IsNullOrEmpty(newResAssetPath))
                {
                    newItemAssetPath = AssetBundleUtil.ToProjectPath(newResAssetPath);
                }
            }
            else if (srcItem.FileType == typeof(Shader))
            {
                string str = FindReplaceShader(asset.name);
                if (string.IsNullOrEmpty(str))
                {
                    Debug.LogError("Find Shader Fail:" + asset.name);
                    continue;
                }
                newItemAssetPath = AssetBundleUtil.ToProjectPath(str);
            }
            else if (srcItem.FileType == typeof(Mesh))  //特殊处理
            {
                string str = FindReplaceMesh(asset.name);
                if (string.IsNullOrEmpty(str))
                {
                    Debug.LogError("Find Mesh Fail:" + asset.name);
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
                    newitem.AssetPath = newItemAssetPath;
                    mReplaceAssetFileInfos.Add(srcItem.FileId, newitem);
                }
            }
        }

        //修改复合资源对内置数据的引用
        foreach (var assetItemInfo in mReplaceAssetFileInfos)
        {
            if (assetItemInfo.Value.FileType == typeof (Material))
            {
                Replace(assetItemInfo.Value.AssetPath);
            }
        }

        //刷新资源
        AssetDatabase.Refresh();

        //foreach (var assetPairItem in mSrcAssetFileInfos)
        //{
        //    long fileiD = assetPairItem.Key;
        //    Debug.Log("<color=red>FileId:" + fileiD + "</color>");
        //    if (mSrcAssetFileInfos.ContainsKey(fileiD))
        //    {
        //        Debug.Log("Src guid:" + mSrcAssetFileInfos[fileiD].Guid + ",name:" + mSrcAssetFileInfos[fileiD].FileName);
        //    }

        //    if (mReplaceAssetFileInfos.ContainsKey(fileiD))
        //    {
        //        Debug.Log("dst guid:" + mReplaceAssetFileInfos[fileiD].Guid + ",name:" + mReplaceAssetFileInfos[fileiD].FileName + ",Path:" + mReplaceAssetFileInfos[fileiD].AssetPath);
        //    }
        //}

        foreach (var guid in mSrcGuids)
        {
            Debug.Log("————————————————————————————————guid:" + guid);
        }
    }

    private AssetItemInfo GetAssetItem(UnityEngine.Object target)
    {
        if (null == target)
        {
            return null;
        }

        AssetItemInfo assetItem = new AssetItemInfo();
        assetItem.FileName = target.name;
        assetItem.Guid = GetGuid(target);
        assetItem.FileId = GetFileID(target);
        assetItem.FileType = target.GetType();
        return assetItem;
    }

    private string ExtractResItem(Object srcAssetItem, bool ForceUpdate = false)
    {
        string newAssetPath = string.Empty;

        if (null == srcAssetItem)
        {
            return newAssetPath;
        }

        Type assetType = srcAssetItem.GetType();
        string name = srcAssetItem.name;
        string path = AssetDatabase.GetAssetPath(srcAssetItem);

        if (assetType == typeof (Shader))  //Shader
        {
            return newAssetPath;
        }

        if (assetType == typeof (Mesh))    //Mesh 直接从工程里面复制
        {
            newAssetPath = ConstReplaceMeshFolder + name + ".fbx";
            return newAssetPath;
        }

        if (assetType == typeof (Material))
        {
            newAssetPath = ConstReplaceMaterialFolder + name + ".mat";
        }
        else if (assetType == typeof(Texture2D) || assetType == typeof(Sprite))
        {
            newAssetPath = ConstReplaceTextureFolder + name + ".png";
        }
        else
        {
            newAssetPath = ConstReplaceResRootFolder + name;
        }

        if (!ForceUpdate && assetType != typeof(Shader))
        {
            UnityEngine.Object targetObj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(newAssetPath);
            if (targetObj != null)
            {
                return newAssetPath;
            }
        }

       // Debug.Log("_______________________________Extract Resources Path:" + newAssetPath + ",Type:" + assetType);

        //提取资源
        if (assetType == typeof(Material))
        {
            Material newMat = new Material(srcAssetItem as Material);
            AssetDatabase.CreateAsset(newMat, newAssetPath);
            AssetDatabase.SaveAssets();

            AssetDatabase.Refresh();
        }
        else if (assetType == typeof(Texture2D))
        {
            bool isSucess = SaveTexture(srcAssetItem as Texture2D, newAssetPath);
            if (isSucess == false)
            {
                newAssetPath = string.Empty;
            }
            else
            {
                AssetDatabase.Refresh();
            }
        }
        else if (assetType == typeof(Sprite))
        {
            Texture2D tex = (srcAssetItem as Sprite).texture;
            bool isSucess = SaveTexture(tex, newAssetPath);
            if (isSucess == false)
            {
                newAssetPath = string.Empty;
            }
            else
            {
                AssetDatabase.Refresh();
            }
        }
        else if (assetType == typeof(Mesh))   //TODO
        {
        }
        else if (assetType == typeof(Shader) || assetType == typeof(MonoScript) || assetType == typeof(LightmapParameters) || assetType == typeof(Font))
        {
        }
        else
        {
            Debug.Log("没有提取的类型 ----- Path:" + path + ", Name:" + name + ",Type:" + assetType);
        }
        return newAssetPath;
    }

    // todo 暂且没实现
    private  void CloneMesh(Mesh srcMesh, string outAssetPath)
    {
        if (srcMesh == null || string.IsNullOrEmpty(outAssetPath))
        {
            return;
        }

        Mesh targetMesh = new Mesh();
        targetMesh.vertices = targetMesh.vertices;
        targetMesh.normals = targetMesh.normals;
        targetMesh.tangents = targetMesh.tangents;
        targetMesh.colors = targetMesh.colors;
        targetMesh.uv = targetMesh.uv;

        AssetDatabase.CreateAsset(targetMesh, outAssetPath);
        AssetDatabase.SaveAssets();
    }

    private bool  SaveTexture(Texture2D tex, string assetPath)
    {
        if (tex == null)
        {
            return false;
        }
        
        //TODO dxt保存为png失败
        if (tex.format == TextureFormat.DXT5 || tex.format == TextureFormat.DXT1)
        {
            return false;
        }

        byte[] bytes = tex.GetRawTextureData();   //不可读
//        Debug.LogError("__________BYte:" + bytes.Length);
//        Debug.LogError("__________Tex:" + tex.width + "," + tex.height + "," + tex.format + "," + tex.mipmapCount);

        Texture2D newTexture = new Texture2D(tex.width, tex.height, tex.format, tex.mipmapCount > 1);

        newTexture.LoadRawTextureData(bytes);

        newTexture.Apply();
        byte[] pngBytes = newTexture.EncodeToPNG();
        Object.DestroyImmediate(newTexture);
        File.WriteAllBytes(assetPath, pngBytes);

        return true;
    }

    private List<string> mShaderFileList = new List<string>();
    private List<string> mMeshFileList = new List<string>();

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
            if (shaderObj != null && shaderObj.name == assetName)
            {
                return shaderPath;
            }
        }

        return String.Empty;
    }

    private string FindReplaceMesh(string assetName)
    {
        if (string.IsNullOrEmpty(assetName))
        {
            return string.Empty;
        }

        string meshFullPath = AssetBundleUtil.ToFullPath(ConstReplaceMeshFolder);

        if (mMeshFileList == null || mMeshFileList.Count == 0)
        {
            mMeshFileList = GetAllTargetFile(meshFullPath);
        }

        foreach (var meshPath in mMeshFileList)
        {
            if (meshPath.ToLower().Contains(assetName.ToLower()))
            {
                return meshPath;
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

    private void SetTextureImportSetting(string assetPath , bool isSprite)
    {
        if (string.IsNullOrEmpty(assetPath))
        {
            return;
        }

        TextureImporter importer = AssetImporter.GetAtPath(assetPath) as TextureImporter;
        if (importer != null)
        {
            if (isSprite)
            {
                importer.textureType = TextureImporterType.Sprite;
                importer.spriteImportMode = SpriteImportMode.Single;
            }
            else
            {
                importer.textureType = TextureImporterType.Default;
            }

            importer.wrapMode = TextureWrapMode.Clamp;
            importer.mipmapEnabled = false;
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


    private static PropertyInfo inspectorMode = typeof(SerializedObject).GetProperty("inspectorMode",
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

    void CreateFolder(string assetFolder)
    {
        string outputFullPath = AssetBundleUtil.ToFullPath(assetFolder);
        if (!Directory.Exists(outputFullPath))
        {
            Directory.CreateDirectory(outputFullPath);
        }
    }
}
