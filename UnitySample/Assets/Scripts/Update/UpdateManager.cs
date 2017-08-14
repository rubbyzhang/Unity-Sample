using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine ;
using  System.Collections ;
using System.IO;
using System.Linq;
using Celf;
using JetBrains.Annotations;


class UpdateManager:Singleton<UpdateManager>
{
    // 加载路径 todo 暂且为streaming路径
    private static string mUpdateUrl = Application.streamingAssetsPath + "/UpdateRes/filelist.text";
    private static string mCurResUrl = Application.streamingAssetsPath + "/AssetBundle/filelist.text";

    public void StartUpdate()
    {
        StartCoroutine(InterUpdate());
    }
    
    public IEnumerator InterUpdate()
    {

        //1. 加载
        Debug.Log("1加载文件列表");
        string curFileStr = "";
        string lastestFileStr = "";

        yield return StartCoroutine(LoadFileList(mCurResUrl, delegate (string str)
        {
            curFileStr = str;
        }));

        yield return StartCoroutine(LoadFileList(mUpdateUrl, delegate (string str)
        {
            lastestFileStr = str;
        }));

        if (string.IsNullOrEmpty(curFileStr))
        {
            Debug.LogError("ResourceUpdateManager.InterUpdate:" + "current file list load failed");
            yield break;
        }
        if (string.IsNullOrEmpty(lastestFileStr))
        {
            Debug.LogError("ResourceUpdateManager.InterUpdate:" + "new  file list load failed");
            yield break;
        }
        
        //2. 解析
        Debug.Log("2解析文件列表");
        Dictionary<string,string> curFiles = ParseFileList(curFileStr);
        Dictionary<string, string> newFiles = ParseFileList(lastestFileStr);

        //3.比对 
        Debug.Log("3比对文件列表");
        List<string> updateList = CompareFileList(curFiles, newFiles);
        if (updateList.Count == 0)
        {
            yield break;
        }

        //4下载最新资源
        Debug.Log("4下载最新文件列表");
        yield return StartCoroutine(UpdateResource(updateList));

        //5 替换文件列表
        Debug.Log("5替换最新文件列表");
        ReplaceLocalRes(mCurResUrl, Encoding.UTF8.GetBytes(lastestFileStr.ToString()));

        Debug.Log("更新完成");
    }

    //  暂且使用分号区分不同的行，逗号区分文件名和MD5数据
    private Dictionary<string,string> ParseFileList(string filesListStr)
    {
        if (string.IsNullOrEmpty(filesListStr))
        {
            DebugError("parse file text failed, filesStr is null");
            return null;
        }

        string[] fileContextList = filesListStr.Split(';');
        if (fileContextList.Length == 0)
        {
            DebugError("Parse File text failed, list is empty");
            return null;
        }


        Dictionary<string,string> fileMd5Map = new Dictionary<string, string>();

        for (int i = 0; i < fileContextList.Length; i++)
        {
            string fileContext = fileContextList[i];

            int index = fileContext.IndexOf("\n");
            if (index >= 0)
            {
                fileContext = fileContext.Substring(index+1);
            }

            if (string.IsNullOrEmpty(fileContext))
            {
                //DebugError("parse file text failed, file Context is null");
                continue;
            }
            
            string[] fileMd5 = fileContext.Split(',');
            if (fileMd5.Length != 2)
            {
                DebugError("parse file text failed, file and md5 is lack");
                continue;
            }

            fileMd5Map.Add(fileMd5[0] , fileMd5[1]);
        }

        return fileMd5Map;
    } 


    private List<string> CompareFileList(Dictionary<string, string> cur , Dictionary<string, string> lastest)
    {
        if ( lastest == null)
        {
            return null;
        }

        if (cur == null)
        {
            return lastest.Keys.ToList();
        }

        List<string> needUpdateList = new List<string>();

        List<string> keys = lastest.Keys.ToList();
        for(int i = 0 ; i < keys.Count ; ++i)
        {
            string key = keys[i];
            string md5 = "";

            if (cur.TryGetValue(key , out md5))
            {
                if (md5 != lastest[key])
                {
                    needUpdateList.Add(key); 
                }   
            }
            else
            {
                needUpdateList.Add(key);
            }
        }
        return needUpdateList; 
    }

    
    private IEnumerator UpdateResource(List<string> needUpdateFileList)
    {
        if (needUpdateFileList == null || needUpdateFileList.Count == 0)
        {
            yield break ;
        }

        for (int i = 0; i < needUpdateFileList.Count; ++ i)
        {
            Debug.Log("更新替换文件：" + needUpdateFileList[i]);
            yield return StartCoroutine(DownLoad(needUpdateFileList[i], delegate(WWW www)
            {
                ReplaceLocalRes(needUpdateFileList[i], www.bytes);
            }) );

        }
    }

    private void ReplaceLocalRes(string fullPath , byte[] data)
    {
        if (string.IsNullOrEmpty(fullPath) || null == data)
        {
            return;
        }
        FileStream stream = new FileStream(fullPath, FileMode.Create);
        stream.Write(data, 0, data.Length);
        stream.Flush();
        stream.Close();
    }

    private IEnumerator LoadFileList(string fullPath, Action<string> finishFun)
    {
        WWW www = new WWW("file://"  + fullPath);
        yield return www;
        if (finishFun != null)
        {
            finishFun(www.text);
        }
        www.Dispose();
    }

    private IEnumerator DownLoad(string url, Action<WWW> finishFun)
    {
        string name = url.Substring( (Application.streamingAssetsPath + "/AssetBundle/" ).Length);
        string streamingPath = "UpdateRes/" + name;
        string path = Application.streamingAssetsPath + "/" + streamingPath;
        
        WWW www = new WWW("file://" + path);
        yield return www;
        if (finishFun != null)
        {
            finishFun(www);
        }
        www.Dispose();
    }
    
    private void DebugError(string str)
    {
        Debug.LogError("ResourceUpdateManager:" + str);
    }
}
