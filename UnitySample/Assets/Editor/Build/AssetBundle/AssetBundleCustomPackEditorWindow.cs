using System;
using UnityEngine;
using UnityEditor;
using AssetBundles ;

public class AssetBundleCustomPackEditorWindow : EditorWindow
{
    public static void AddWindow()
    {
        //创建窗口
        Rect wr = new Rect(0, 0, 350, 500);
        AssetBundleCustomPackEditorWindow window = (AssetBundleCustomPackEditorWindow)EditorWindow.GetWindowWithRect(typeof(AssetBundleCustomPackEditorWindow), wr, true, "Pack Bundle");
        window.Show();
    }

    enum BuildTargetPlatform
    {
        StandaloneWindows,
        Android,
        IOS,
    }

    private BuildTargetPlatform currentPaltform = BuildTargetPlatform.StandaloneWindows;

    public void Awake()
    {
        BuildTarget target = EditorUserBuildSettings.activeBuildTarget;
        if (target == BuildTarget.StandaloneWindows)
        {
            currentPaltform = BuildTargetPlatform.StandaloneWindows;
        }
        else if (target == BuildTarget.Android)
        {
            currentPaltform = BuildTargetPlatform.Android;
        }
        else if (target == BuildTarget.iOS)
        {
            currentPaltform = BuildTargetPlatform.IOS;
        }
    }

    void OnGUI()
    {
        EditorGUILayout.Separator();

        EditorGUILayout.BeginVertical();
        BuildTarget buildTarget = BuildTarget.Android;
        currentPaltform = (BuildTargetPlatform)EditorGUILayout.EnumPopup("目标平台选择:", currentPaltform);
        if (currentPaltform == BuildTargetPlatform.StandaloneWindows)
        {
            buildTarget = BuildTarget.StandaloneWindows;
        }
        else if (currentPaltform == BuildTargetPlatform.Android)
        {
            buildTarget = BuildTarget.Android;
        }
        else if (currentPaltform == BuildTargetPlatform.IOS)
        {
            buildTarget = BuildTarget.iOS;
        }
        EditorGUILayout.EndVertical();

        EditorGUILayout.Separator();
        EditorGUILayout.Separator();
        EditorGUILayout.Separator();

        EditorGUILayout.BeginVertical();
        foreach (var bundleType in Enum.GetValues(typeof(BundleType)))
        {
            if ((BundleType)bundleType != BundleType.Max)
            {
                if (GUILayout.Button(bundleType.ToString(), GUILayout.Width(300), GUILayout.Height(24)))
                {
                    GameBuildPipeline_AssetBundle.BuildPlatformAll(buildTarget, (BundleType)bundleType);
                }
            }
            else
            {
                GUILayout.FlexibleSpace();
                if (GUILayout.Button(bundleType.ToString(), GUILayout.Width(300), GUILayout.Height(30)))
                {
                    GameBuildPipeline_AssetBundle.BuildPlatformAll(buildTarget, BundleType.Max);
                }
            }
        }
        EditorGUILayout.EndVertical();

        EditorGUILayout.Separator();
    }

    void OnFocus()
    {
        //Debug.Log("当窗口获得焦点时调用一次");
    }

    void OnLostFocus()
    {
        //Debug.Log("当窗口丢失焦点时调用一次");
    }

    void OnHierarchyChange()
    {
        //Debug.Log("当Hierarchy视图中的任何对象发生改变时调用一次");
    }

    void OnProjectChange()
    {
        //Debug.Log("当Project视图中的资源发生改变时调用一次");
    }

    void OnInspectorUpdate()
    {
        //Debug.Log("窗口面板的更新");
        //这里开启窗口的重绘，不然窗口信息不会刷新
        this.Repaint();
    }

    void OnSelectionChange()
    {
        //当窗口出去开启状态，并且在Hierarchy视图中选择某游戏对象时调用
        foreach (Transform t in Selection.transforms)
        {
            //有可能是多选，这里开启一个循环打印选中游戏对象的名称
            Debug.Log("OnSelectionChange" + t.name);
        }
    }

    void OnDestroy()
    {
        //Debug.Log("当窗口关闭时调用");
    }

}