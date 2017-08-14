using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Text;


/// <summary>
/// 运行时 根据场景名字查找场景路径
/// </summary>
public class LoadSceneBuildSettings : Celf.Singleton<LoadSceneBuildSettings>
{
    private Dictionary<string,string> scenePathDictionary = new Dictionary<string, string>();

    private bool mIsInit = false;

    private readonly string ConstAssetPath = "settings/SceneBuildSettings";

    protected override void OnInit()
    {
        Init();
    }

    public void Init()
    {
        if (!mIsInit)
        {
//#if UNITY_EDITOR   
//            UnityEditor.EditorBuildSettingsScene[] editorBuildSettingsScenes = UnityEditor.EditorBuildSettings.scenes;
//            for (int i = 0; i < editorBuildSettingsScenes.Length; i++)
//            {
//                string scenePath = editorBuildSettingsScenes[i].path;
//                scenePath = scenePath.Substring(0, scenePath.LastIndexOf("."));
//                scenePath = scenePath.Substring("Assets/".Length);
//                string sceneName = scenePath.Substring(scenePath.LastIndexOf("/") + 1);
//                scenePathDictionary[sceneName] = scenePath;
//            }

//#else
            SceneBuildSettings sceneBuildSettings = ResourceService.Instance.Load<SceneBuildSettings>(ConstAssetPath);
            for (int i = 0; i < sceneBuildSettings.ScenePaths.Count; ++i)
            {
                scenePathDictionary[sceneBuildSettings.SceneNames[i]] = sceneBuildSettings.ScenePaths[i];
            }
            DestroyImmediate(sceneBuildSettings);
//#endif
            mIsInit = true;
        }
    }

    public string GetScenePath(string sceneName)
    {
        if (string.IsNullOrEmpty(sceneName))
        {
            return string.Empty;
        }

        if (scenePathDictionary.ContainsKey(sceneName))
        {
            return scenePathDictionary[sceneName];
        }
        return string.Empty;
    }
}
