using System;
using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections;
using System.Diagnostics;
using Debug = UnityEngine.Debug;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using AssetBundles;

public static class GameBuildPipeline_Platform
{
    public const string ABRoot = "../Build/DataExport/";
    public const string DataRoot = "Data/";
    public const string BuildToolRoot = "../Build/DataExport/buildtool/";
    public const string BuildTempRoot = ABRoot + "vfstemp/";

    private const string srcRoot = "Assets/Resources/";
    private const string dstRoot = ABRoot + "restemp/";
    private static string[] moveDirs = AssetBundleConfig.GetPackTargetPathUnderResourcesPath();

    public static int BUILD_TAG = 0;

    public static string GetBuildDataExportPath(BuildTarget target)
    {
        string exportPath = string.Empty;
        switch (target)
        {
            case BuildTarget.Android:
                exportPath = ABRoot + "Android/data";
                break;
            case BuildTarget.iOS:
                exportPath = ABRoot + "iOS/data";
                break;
            case BuildTarget.StandaloneWindows:
                exportPath = ABRoot + "Win32/data";
                break;
            default:
                Debug.LogError("Critical Error! BuildTarget is not valid");
                break;
        }

        return exportPath;
    }
    public static string GetBuildTargetPath(BuildTarget target)
    {
        string exportPath = string.Empty;
        if (BUILD_TAG == 0)
        {
            switch (target)
            {
                case BuildTarget.Android:
                    exportPath = "../Build/Android";
                    break;
                case BuildTarget.iOS:
                    exportPath = "../Build/iOS";
                    break;
                case BuildTarget.StandaloneWindows:
                    exportPath = "../Build/Win32";
                    break;
                default:
                    Debug.LogError("Critical Error! BuildTarget is not valid");
                    break;
            }
        }
        else if (BUILD_TAG == 1)
        {
            switch (target)
            {
                case BuildTarget.Android:
                    exportPath = "../Build/Battle/Android";
                    break;
                case BuildTarget.iOS:
                    exportPath = "../Build/Battle/iOS";
                    break;
                case BuildTarget.StandaloneWindows:
                    exportPath = "../Build/Battle/Win32";
                    break;
                default:
                    Debug.LogError("Critical Error! BuildTarget is not valid");
                    break;
            }
        }
        else if(BUILD_TAG == 2) 
        {
            switch (target)
            {
                case BuildTarget.Android:
                    exportPath = "../Build/BattleTest/Android";
                    break;
                case BuildTarget.iOS:
                    exportPath = "../Build/BattleTest/iOS";
                    break;
                case BuildTarget.StandaloneWindows:
                    exportPath = "../Build/BattleTest/Win32";
                    break;
                default:
                    Debug.LogError("Critical Error! BuildTarget is not valid");
                    break;
            }
        }
        else if (BUILD_TAG == 3)
        {
            switch (target)
            {
                case BuildTarget.Android:
                    exportPath = "../Build/BattleTest/Android";
                    break;
                case BuildTarget.iOS:
                    exportPath = "../Build/BattleTest/iOS";
                    break;
                case BuildTarget.StandaloneWindows:
                    exportPath = "../Build/BattleTest/Win32";
                    break;
                default:
                    Debug.LogError("Critical Error! BuildTarget is not valid");
                    break;
            }
        }
        return exportPath;
    }

    public static void CopyFile(string srcPath, string dstPath)
    {
        string dstDir = Path.GetDirectoryName(dstPath);
        if (!Directory.Exists(dstDir))
        {
            Directory.CreateDirectory(dstDir);
        }

        if (File.Exists(dstPath))
        {
            File.SetAttributes(dstPath, FileAttributes.Normal);
        }

        File.Copy(srcPath, dstPath, true);
        Debug.Log(string.Format("CopyFile: {0} => {1}", srcPath, dstPath));
    }

    public static void MoveFile(string filePath, string toPath)
    {
        if (!File.Exists(filePath))
        {
            return;
        }

        string toDir = Path.GetDirectoryName(toPath);
        if (!Directory.Exists(toDir))
        {
            Directory.CreateDirectory(toDir);
        }

        try
        {
            File.Move(filePath, toPath);
        }
        catch (Exception e)
        {
            Debug.Log("Move Fail From path:" + filePath + " to path:" + toPath);
            throw e;
        }
    }

    public static void CopyDir(string srcDir, string dstDir, string pattern = null)
    {
        if (!Directory.Exists(srcDir))
        {
            return;
        }

        if (!Directory.Exists(dstDir))
        {
            Directory.CreateDirectory(dstDir);
        }

        string[] strDirs = Directory.GetDirectories(srcDir);
        foreach (string strdir in strDirs)
        {
            string dir = Path.GetFileName(strdir);
            CopyDir(Path.Combine(srcDir, dir), Path.Combine(dstDir, dir), pattern);
        }

        string[] files = null;
        if (string.IsNullOrEmpty(pattern))
        {
            files = Directory.GetFiles(srcDir);
        }
        else
        {
            files = Directory.GetFiles(srcDir, pattern);
        }

        foreach (string s in files)
        {
            string fileName = Path.GetFileName(s);
            string destFile = Path.Combine(dstDir, fileName);
            File.Copy(s, destFile, true);
        }
    }

    //move "a/dir/" to "b/dir"
    public static void MoveDir(string srcDir, string dstDir)
    {
        if (!Directory.Exists(srcDir))
        {
            return;
        }

        DirectoryInfo parentInfo = Directory.GetParent(dstDir);
        if (parentInfo == null)
        {
            return;
        }

        if (!parentInfo.Exists)
        {
            Directory.CreateDirectory(parentInfo.FullName);
        }
        else
        {
            DeleteDir(dstDir);
        }

        Directory.Move(srcDir, dstDir);
    }

    public static void DeleteDir(string dir)
    {
        if (Directory.Exists(dir))
        {
            string[] strDirs = Directory.GetDirectories(dir);
            foreach (string strdir in strDirs)
            {
                DeleteDir(strdir);
            }

            string[] strFiles = Directory.GetFiles(dir);
            foreach (string strFile in strFiles)
            {
                if (File.Exists(strFile))
                {
                    File.SetAttributes(strFile, FileAttributes.Normal);
                    File.Delete(strFile);
                }
            }

            Directory.Delete(dir);
        }
    }

    public static bool RenameFile(string oldName, string newName)
    {
        try
        {
            if (File.Exists(newName))
            {
                File.Delete(newName);
            }
            FileInfo fileInfo = new FileInfo(oldName);
            fileInfo.MoveTo(newName);
        }
        catch (System.Exception ex)
        {
            Debug.LogError(ex);
            return false;
        }

        return true;
    }

    /*private static void CreateIFS(BuildTarget target)
    {
        string packagerPath = BuildToolRoot + "Packager.exe";
        string rootPath = GetBuildDataExportPath(target);
        string ifsPath = rootPath + "/../data.ifs";
        string arg = string.Format("new -createalways -zip=lzma {0} {1}", ifsPath, rootPath);

        CmdExecute(packagerPath, arg, false, false);

        CopyFile(ifsPath, "./Assets/StreamingAssets/data.ifs");
        AssetDatabase.Refresh();
    }*/

	private static void CreateIFS(BuildTarget target)
	{
		//string packagerPath = BuildToolRoot + "Packager.exe";
		string rootPath = GetBuildDataExportPath(target);
		string ifsPath = rootPath + "/../data.ifs";
		//string arg = string.Format("new -createalways -zip=lzma {0} {1}", ifsPath, rootPath);

		if (File.Exists(ifsPath))
		{
			File.SetAttributes(ifsPath, FileAttributes.Normal);
			File.Delete(ifsPath);
		}

		if (Application.platform == RuntimePlatform.WindowsEditor)
		{
			Debug.Log("[CreateIFS] WindowsEditor");
			Debug.Log("[CreateIFS] root path = " + rootPath);

			string packagerPath = BuildToolRoot + "Packager.exe";
			string arg = string.Format("new -createalways -zip=lzma {0} {1}", ifsPath, rootPath);

			CmdExecute(packagerPath, arg, false, false);
		}
		else if (Application.platform == RuntimePlatform.OSXEditor)
		{
			Debug.Log("[CreateIFS] OSXEditor");

			string packagerPath = BuildToolRoot + "nifs";

			// NOTE: package tool on MacOS NOT include the last path element of the input path in the output ifs
			rootPath = Directory.GetParent(rootPath).FullName;

			Debug.Log("[CreateIFS] root path = " + rootPath);

			string arg = string.Format("create {0} {1}", rootPath, ifsPath);

			// Debug.Log (string.Format("[CreateIFS] {0} {1}", packagerPath, arg));

			CmdExecute(packagerPath, arg, false, false);
		}

		//CmdExecute(packagerPath, arg, false, false);

		CopyFile(ifsPath, "./Assets/StreamingAssets/data.ifs");
		//AssetDatabase.Refresh();
	}
    public static void CmdExecute(string exe, string arg, bool shell, bool hidden)
    {
        try
        {
            Process packager = new Process();
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = exe;
            startInfo.Arguments = arg;
            startInfo.UseShellExecute = shell;
            startInfo.WindowStyle = hidden ? ProcessWindowStyle.Hidden : ProcessWindowStyle.Normal;
            packager.StartInfo = startInfo;
            packager.Start();
            packager.WaitForExit();
        }
        catch (System.Exception ex)
        {
            Debug.LogError(ex);
        }
    }

    public static void BuildIFSPack(BuildTarget target)
    {
        StartTimeRecorder("Build IFS Pack");

        CreateIFS(target);

        StopTimeRecorder("Build IFS Pack");

    }

    private const string versionPath = "Assets/Resources/LiveUpdate/Version.txt";
    [MenuItem("Build/Android Data + Version")]
    private static void CreateAndroidIfsJsonTest()
    {
        string version = ReadVersionString(versionPath);
        CreateDataIfsVersion(BuildTarget.Android, version);
    }

    [MenuItem("Build/Android Apk + Version")]
    public static void CreateApkVersionTest()
    {
        string apkName = GetBuildTargetPath(BuildTarget.Android) + "/hl.apk";
        string version = ReadVersionString(versionPath);
        CreateApkVersion(apkName, version);
    }

    public static bool CreateApkVersion(string fileName, string version)
    {
        //HLClient.apk => HLClient_1.2.3.4.apk
        if (!File.Exists(fileName))
        {
            Debug.LogError("GameBuildPipeline_Platform.CreateApkVersion() fail! file not exist: " + fileName);
            return false;
        }

        string ext = Path.GetExtension(fileName);
        string dir = Path.GetDirectoryName(fileName);
        string fileNameNoExt = Path.GetFileNameWithoutExtension(fileName);
        string newName = string.Format("{0}/{1}_{2}{3}", dir, fileNameNoExt, version, ext);

        if (!RenameFile(fileName, newName))
        {
            return false;
        }

        CreateApkJson(newName, version);

        return true;
    }

    public static bool CreateDataIfsVersion(BuildTarget target, string version)
    {
        string rootPath = GetBuildDataExportPath(target);
        string ifsPath = rootPath + "/../data.ifs";

        if (!File.Exists(ifsPath))
        {
            Debug.LogError("GameBuildPipeline_Platform.CreateDataIfsVersion() fail! file not exist: " + ifsPath);
            return false;
        }

        //data.ifs => data_1.2.3.4.ifs
        string dir = Path.GetDirectoryName(ifsPath);
        string versionIfsFullName = dir + string.Format("/data_{0}.ifs", version);

        if (!RenameFile(ifsPath, versionIfsFullName))
        {
            return false;
        }

        Debug.Log(string.Format("Rename {0} to {1}", ifsPath, Path.GetFileName(versionIfsFullName)));

        CreateIfsJson(versionIfsFullName);
        return true;
    }

    private static void CreateApkJson(string versionIfsFullName, string version)
    {
        JsonAPK(versionIfsFullName, version);
    }

    private static void CreateIfsJson(string versionIfsFullName)
    {
        JsonIFS(versionIfsFullName);
    }

    public static string GetCommandLineVersion()
    {
        string version = string.Empty;
        string[] args = System.Environment.GetCommandLineArgs();
        if (args != null && args.Length > 10)
        {
            version = args[10];
        }
        return version;
    }

    #region ifs file system & live update

    //[MenuItem("Build Bundles/MD5")]
    private static string MD5(string filePath)
    {
        Debug.Log("md5 start-------------------------------------\nfile:" + filePath);
        using (System.Security.Cryptography.MD5 md5Hash = System.Security.Cryptography.MD5.Create())
        {
            string hash = GetMd5Hash(md5Hash, filePath);
            Debug.Log(string.Format("ok! MD5: {0}", hash));
            return hash;
        }
    }

    private static string GetMd5Hash(System.Security.Cryptography.MD5 md5Hash, string filePath)
    {
        using (FileStream fs = File.Open(filePath, FileMode.Open))
        {
            byte[] data = md5Hash.ComputeHash(fs);
            System.Text.StringBuilder sBuilder = new System.Text.StringBuilder();

            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }

            return sBuilder.ToString();
        }
    }

    //[MenuItem("Build Bundles/Json -APK")]
    public static void JsonAPK(string apkFullName, string version)
    {
        Debug.Log("Json APK------------------------------------------");

        FileInfo fileInfo = new FileInfo(apkFullName);
        string fileSize = fileInfo.Length.ToString();
        string apkName = Path.GetFileName(apkFullName);

        string jsonString = string.Format(
            @"{{
""full"":
    {{
        ""url"": ""{0}"",
        ""filesize"":{1},
        ""toversion"": ""{2}"",
        ""completedmd5"": ""{3}"",
        ""versionInterval"":5,
        ""fullapkname"": ""{4}""
    }}
}}",
            "http://dlied5.myapp.com/myapp/1104558427/full/" + apkName, fileSize, version, MD5(apkFullName), apkName);

        string jsonFile = apkFullName + ".json";
        using (FileStream fs = File.Open(jsonFile, FileMode.OpenOrCreate, FileAccess.Write))
        {
            byte[] utf8Bytes = System.Text.Encoding.UTF8.GetBytes(jsonString);
            fs.Write(utf8Bytes, 0, utf8Bytes.Length);
            fs.Flush();
            Debug.Log("create file ok:" + jsonFile);
        }
    }

    //[MenuItem("Build Bundles/Json -IFS")]
    public static void JsonIFS(string ifsfullName)
    {
        Debug.Log("Json IFS------------------------------------------");
        FileInfo fileInfo = new FileInfo(ifsfullName);
        string fileSize = fileInfo.Length.ToString();
        string ifsName = Path.GetFileName(ifsfullName);

        string jsonString = string.Format(
            @"{{
""filelist"":
	[
		{{
			""url"": ""{0}"",
			""filename"": ""{1}"",
			""filesize"":{2}
		}}
	]
}}",
            "http://dlied5.myapp.com/myapp/1104558427/patch/" + ifsName, ifsName, fileSize);

        string jsonFile = ifsfullName + ".json";
        using (FileStream fs = File.Open(jsonFile, FileMode.OpenOrCreate, FileAccess.Write))
        {
            byte[] utf8Bytes = System.Text.Encoding.UTF8.GetBytes(jsonString);
            fs.Write(utf8Bytes, 0, utf8Bytes.Length);
            fs.Flush();
            Debug.Log("create file ok:" + jsonFile);
        }
    }

    #endregion

    //[MenuItem("Build/Move Resources Away", false, 40)]
    public static void MoveResourcesAway()
    {
        DeleteDir(dstRoot);
        foreach (var dir in moveDirs)
        {
            if (Directory.Exists(srcRoot + dir))
            {
                MoveDir(srcRoot + dir, dstRoot + dir);
            }
            else
            {
                MoveFile(srcRoot + dir, dstRoot + dir);
            }
            MoveFile(srcRoot + dir + ".meta", dstRoot + dir + ".meta");
        }
    }

    //[MenuItem("Build/Move Resources Back", false, 40)]
    public static void MoveResourcesBack()
    {
        foreach (var dir in moveDirs)
        {
            if (Directory.Exists(dstRoot + dir))
            {
                MoveDir(dstRoot + dir, srcRoot + dir);
            }
            else
            {
                MoveFile(dstRoot + dir, srcRoot + dir);
            }

            MoveFile(dstRoot + dir + ".meta", srcRoot + dir + ".meta");
        }
    }
    
    private static string ReadVersionString(string filePath)
    {
        string version = "0.0.0.0";
        using (StreamReader reader = File.OpenText(filePath))
        {
            string line = reader.ReadLine();
            if (!string.IsNullOrEmpty(line) && line.Length >= version.Length)
            {
                version = line;
            }
        }
        return version;
    }

    public static string[] GetBuildScene(BuildTarget target)
    {        
        if (BUILD_TAG == 0)
        {
            var names = (from e in EditorBuildSettings.scenes where e != null where e.enabled select e.path).ToList();
            if (target != BuildTarget.StandaloneWindows) return names.ToArray();

            names.RemoveAt(0);


            return names.ToArray();
        }
        else if(BUILD_TAG == 1)
        {
            List<string> names = new List<string>();
            if (target == BuildTarget.Android || target == BuildTarget.iOS)
            {
                names.Add("Assets/Scenes/Update_Battle.unity");
            }
            names.Add("Assets/Scenes/Battle.unity");
            names.Add("Assets/Scenes/BattleMaps/tushancun_b01.unity");
            //if (target == BuildTarget.Android || target == BuildTarget.iOS)
            //{
            //    names.Add("Assets/Scenes/Update.unity");
            //}
            names.Add("Assets/Scenes/Lobby.unity");
            return names.ToArray();
        }
        else if (BUILD_TAG == 2)
        {
            List<string> names = new List<string>();
            if (target == BuildTarget.Android || target == BuildTarget.iOS)
            {
//                names.Add("Assets/Scenes/Update_BattleMerge.unity");
            }
            names.Add("Assets/Scenes/Cinematic.unity");
            return names.ToArray();
        }
        else if (BUILD_TAG == 3)
        {
            List<string> names = new List<string>();
            if (target == BuildTarget.Android || target == BuildTarget.iOS)
            {
                names.Add("Assets/Scenes/Update_BattleMerge.unity");
            }
            names.Add("Assets/Scenes/BattleMergeTest.unity");
            return names.ToArray();
        }
        else
        {
            List<string> names = new List<string>();

            return names.ToArray();
        }
    }

    public static BuildOptions GetBuildOptions(BuildTarget target)
    {
        var option = BuildOptions.None;
        if (BUILD_TAG == 3)
        {
            option = BuildOptions.Development | BuildOptions.ConnectWithProfiler;//| BuildOptions.AllowDebugging | BuildOptions.ConnectToHost;
        }

        return option;
    }

    public static void PreBuild(BuildTarget target, bool buildWithAB = false)
    {
        StartTimeRecorder("Prepare Build Data");

        //Scene Setting
        GenarateBuildSettings();

        //Atlas
        GenarateUIAtlas(buildWithAB);

        StopTimeRecorder("Prepare Build Data");
    }

    //Atlas
    public static void GenarateUIAtlas(bool isUsingAssetBundle)
    {
        if (isUsingAssetBundle)
        {
            GameBuildPipeline_Platform.DeleteDir("Resources/atlas");
        }
        else
        {
            AtlasPacker.PackAllAtlas();
        }
    }

    /// <summary>
    /// 根据BuildSetting 保存场景设置数据
    /// </summary>
    public static void GenarateBuildSettings()
    {
        SceneBuildSettings configs = ScriptableObject.CreateInstance<SceneBuildSettings>();
        EditorBuildSettingsScene[] editorBuildSettingsScenes = EditorBuildSettings.scenes;
        for (int i = 0; i < editorBuildSettingsScenes.Length; i++)
        {
            string scenePath = editorBuildSettingsScenes[i].path;
            scenePath = scenePath.Substring(0, scenePath.LastIndexOf("."));
            scenePath = scenePath.Substring(scenePath.IndexOf("Assets/"));
            string sceneName = scenePath.Substring(scenePath.LastIndexOf("/") + 1);

            configs.ScenePaths.Add(scenePath);
            configs.SceneNames.Add(sceneName);
        }
        AssetDatabase.CreateAsset(configs, "Assets/Resources/settings/SceneBuildSettings.asset");
    }

    //设置Cache Server , 默认值根据实际需求进行修改
    public static void SetCacheServer(bool enable, string ipAddr = "10.8.21.74")
    {
        //1 获取程序集
        Assembly asm = Assembly.GetAssembly(typeof(UnityEditor.AssetImporter));
        if (asm == null)
        {
            return;
        }

        //2 UnityEditor 内部类
        Type cacheServerType = asm.GetType("UnityEditor.CacheServerPreferences");

        //3 创建实例
        object cacheServerPreferencesObj = System.Activator.CreateInstance(cacheServerType);

        //4 通过反射读取已设置的参数
        MethodInfo readPreferencesMethod = cacheServerType.GetMethod("ReadPreferences");
        readPreferencesMethod.Invoke(cacheServerPreferencesObj, null);

        //5 通过反射设置CacheServer 参数
        FieldInfo CacheServerMode = cacheServerType.GetField("s_CacheServerMode", BindingFlags.NonPublic | BindingFlags.Static);
        FieldInfo CacheServerIPAddress = cacheServerType.GetField("s_CacheServerIPAddress", BindingFlags.NonPublic | BindingFlags.Static);

        CacheServerMode.SetValue(cacheServerPreferencesObj, enable ? 1 : 2);
        CacheServerIPAddress.SetValue(cacheServerPreferencesObj, ipAddr);

        //6 通过反射 保存 CacheServer 参数
        MethodInfo writePreferencesMethod = cacheServerType.GetMethod("WritePreferences");
        writePreferencesMethod.Invoke(cacheServerPreferencesObj, null);
    }

    /// <summary>
    /// Build Player 后回调
    /// </summary>
    public static void OnPostprocessBuild(BuildTarget target, string pathToBuiltProject)
    {
        Debug.Log(">>>>>>>>>>>>>>>>>>>>>>OnPostprocessBuild " + pathToBuiltProject);
    }

    public static void StartTimeRecorder(string keyword)
    {
        Debug.Log("....................................................GameBuildPipeline Start    >>>>>>>> Content:" + keyword);
        EditorTimeRecorderManager.Start(keyword);
    }

    public static void StopTimeRecorder(string keyword)
    {
        double gap = EditorTimeRecorderManager.Stop(keyword);
        Debug.Log("...................................................GameBuildPipeline Complete >>>>>>>> Content:" + keyword + ", Cost Time(s):" + gap);
    }
}