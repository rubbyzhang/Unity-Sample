using System.Collections.Generic;
using System.Text;
using  System.IO ;
using UnityEngine ;

public class UpdateFileCollector
{
    private static string OutPutPath = Application.streamingAssetsPath + "/AssetBundle/";

    private static  Dictionary<string , string> mFileMd5Map = new Dictionary<string, string>(); 

    public static void Collect()
    {
        GetAssetBundleFileList();
        GetLuaFileList();
        SaveFileList();
    }

    private static void SaveFileList()
    {
        StringBuilder content = new StringBuilder();
        foreach ( KeyValuePair<string,string> file in mFileMd5Map)
        {
            string str = file.Key + "," + file.Value + " ; \n";
            content.Append(str);
        }
        
        FileStream stream = new FileStream(OutPutPath + "filelist.text", FileMode.Create);
        byte[] data = Encoding.UTF8.GetBytes(content.ToString());
        stream.Write(data, 0, data.Length);
        stream.Flush();
        stream.Close();
    }

    private static void GetAssetBundleFileList()
    {
        mFileMd5Map.Clear();

        string assetBundlePath = "";
        //string assetBundlePath = AssetBundleConfig.GetAssetBundleOutputPath();

        DirectoryInfo folder = new DirectoryInfo(assetBundlePath);
        if (!folder.Exists)
        {
            Debug.LogError("ResetAssetBundleName Error, Path(" + assetBundlePath + ") miss");
            return;
        }

        FileSystemInfo[] files = folder.GetFileSystemInfos();
        foreach (var file in files)
        {
            if (file is DirectoryInfo)
            {
                //todo
                continue;
            }
            else
            {
                if (!file.FullName.EndsWith(".meta"))
                {
                    string fullPath = file.FullName.Replace("\\", "/");
                    string md5 = MD5Util.GetFileMD5(fullPath);
                    mFileMd5Map.Add(fullPath, md5);
                }
            }
        }
    }
    
    private static void GetLuaFileList()
    {
            
    }
}
