using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;

public class EditorTimeRecorder : MonoBehaviour
{
    private double mStartTime = 0;
    private double mStopTime = 0;
    private string mKeyWord = "";

    public EditorTimeRecorder(string keyword)
    {
        mKeyWord = keyword;
    }

    public void StartRecorder()
    {
        mStartTime = EditorApplication.timeSinceStartup;
    }

    public double StopRecorder()
    {
        mStopTime = EditorApplication.timeSinceStartup;
        return mStopTime - mStartTime;
    }

    public void Reset()
    {
        mStartTime = 0;
        mStopTime = 0;
    }
}

public class EditorTimeRecorderManager
{
    static Dictionary<string,EditorTimeRecorder> mEditorTimeRecorders = new Dictionary<string, EditorTimeRecorder>();

    public static void Start(string keyword)
    {
        if (string.IsNullOrEmpty(keyword))
        {
            return;
        }

        if (mEditorTimeRecorders.ContainsKey(keyword))
        {
            mEditorTimeRecorders[keyword].StartRecorder();
        }
        else
        {
            EditorTimeRecorder recorder = new EditorTimeRecorder(keyword);
            mEditorTimeRecorders[keyword] = recorder;
            recorder.StartRecorder();
        }
    }

    public static double Stop(string keyword)
    {
        if (string.IsNullOrEmpty(keyword))
        {
            return 0;
        }

        if (mEditorTimeRecorders.ContainsKey(keyword))
        {
            double gap =  mEditorTimeRecorders[keyword].StopRecorder();
            mEditorTimeRecorders.Remove(keyword);
            return gap;
        }
        return 0;
    }
}
