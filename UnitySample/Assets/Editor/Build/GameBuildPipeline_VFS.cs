using System;
using UnityEngine;
using System.Collections;
using System.IO;
using UnityEditor;
using Celf;

public class GameBuildPipeline_VFS
{
    private static string dataRoot = GameBuildPipeline_Platform.DataRoot;
    private static string buildToolRoot = GameBuildPipeline_Platform.BuildToolRoot;
    private static string buildTempRoot = GameBuildPipeline_Platform.BuildTempRoot;

    public static void BuildVFS(BuildTarget target)
    {
        GameBuildPipeline_Platform.StartTimeRecorder("BuildVFS");
        try
        {
#if COMPATIBILITY_FLUX
            FluxEditor.SeekAndSaveHitPoints.Open();
#endif

            //string exportVFSRoot = GameBuildPipeline_Platform.GetBuildDataExportPath(target) + "/vfs/";
            string exportVFSRoot = GameBuildPipeline_Platform.GetBuildDataExportPath(target) + "/";

            GameBuildPipeline_Platform.DeleteDir(exportVFSRoot + "audio/");
            GameBuildPipeline_Platform.DeleteDir(exportVFSRoot + "data1.bytes");
            GameBuildPipeline_Platform.DeleteDir(exportVFSRoot + "data2.bytes");

            Directory.CreateDirectory(exportVFSRoot + "audio/");

            GameBuildPipeline_Platform.DeleteDir(buildTempRoot);
            Directory.CreateDirectory(buildTempRoot);

            switch (target)
            {
                case BuildTarget.Android:
                {
                    //BuildLuajit(dataRoot + "scripts/", buildTempRoot + "scripts/");
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "scripts/", buildTempRoot + "scripts/", "*.lua");
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "scripts/", buildTempRoot + "scripts/", "*.proto");
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "audio/android", buildTempRoot + "audio/", "*.bnk");

                    //下面的wem文件不用打包到vfs中，所以直接拷贝到vfs同级目录
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "audio/android", exportVFSRoot + "audio/", "*.wem");
                    break;
                }
                case BuildTarget.StandaloneWindows:
                {
                    //BuildLuajit(dataRoot + "scripts/", buildTempRoot + "scripts/");
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "scripts/", buildTempRoot + "scripts/", "*.lua");
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "scripts/", buildTempRoot + "scripts/", "*.proto");
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "audio/Windows", buildTempRoot + "audio/", "*.bnk");

                    //下面的wem文件不用打包到vfs中，所以直接拷贝到vfs同级目录
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "audio/Windows", exportVFSRoot + "audio/", "*.wem");

                    GameBuildPipeline_Platform.CopyDir(dataRoot + "scripts/", exportVFSRoot + "scripts/", "*.lua");
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "scripts/", exportVFSRoot + "scripts/", "*.proto");
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "audio/Windows", exportVFSRoot + "audio/", "*.bnk");
                    break;
                }
                case BuildTarget.iOS:
                {
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "scripts/", buildTempRoot + "scripts/", "*.lua");
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "scripts/", buildTempRoot + "scripts/", "*.proto");
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "audio/ios/", buildTempRoot + "audio/", "*.bnk");

                    //下面的wem文件不用打包到vfs中，所以直接拷贝到vfs同级目录
                    GameBuildPipeline_Platform.CopyDir(dataRoot + "audio/ios", exportVFSRoot + "audio/", "*.wem");
                    break;
                }
                default:
                    Debug.LogError("Critical Error! BuildTarget is not valid");
                    break;
            }

            BuildDir(buildTempRoot + "scripts/", buildTempRoot + "vfs/data1.bytes");
            BuildDir(buildTempRoot + "audio/", buildTempRoot + "vfs/data2.bytes");

            GameBuildPipeline_Platform.CopyFile(buildTempRoot + "vfs/data1.bytes", exportVFSRoot + "data1.bytes");
            GameBuildPipeline_Platform.CopyFile(buildTempRoot + "vfs/data2.bytes", exportVFSRoot + "data2.bytes");
        }
        catch (Exception ex)
        {
            Debug.LogError(ex.Message);
        }

        GameBuildPipeline_Platform.StopTimeRecorder("BuildVFS");
    }

    private static void BuildLuajit(string srcDir, string dstDir)
    {
        string exe = buildToolRoot + "luajit/luajitcompile.bat";
        exe = Path.GetFullPath(exe);
        srcDir = Path.GetFullPath(srcDir);
        dstDir = Path.GetFullPath(dstDir);
        if (srcDir.EndsWith("\\") || srcDir.EndsWith("/"))
        {
            srcDir = srcDir.Remove(srcDir.Length - 1, 1);
        }
        if (dstDir.EndsWith("\\") || dstDir.EndsWith("/"))
        {
            dstDir = dstDir.Remove(dstDir.Length - 1, 1);
        }
        string arg = string.Format("{0} {1}", srcDir, dstDir);
        GameBuildPipeline_Platform.CmdExecute(exe, arg, true, true);
    }

    private static void BuildDir(string srcPath, string dstPath)
    {
        DoBuild(srcPath, dstPath);
    }

    private static bool DoBuild(string inPath, string outPath)
    {
        // 删除输出文件
        if (File.Exists(outPath))
        {
            File.SetAttributes(outPath, FileAttributes.Normal);
            File.Delete(outPath);
        }
        else
        {
            string outDirPath = Path.GetDirectoryName(outPath);
            if (outDirPath != null)
            {
                Directory.CreateDirectory(outDirPath);
            }
        }

        //// 新建输出文件并进行编辑
        //VirtualFileSystem fs = new VirtualFileSystem();
        //if (!fs.Open(outPath, VirtualFileSystem.FileMode.fileModeEdit))
        //{
        //    Debug.LogError("Build VFS failed : " + outPath + " cannot open vfs file!");
        //    return false;
        //}

        //string currentDir = Directory.GetCurrentDirectory();
        //Directory.SetCurrentDirectory(inPath);

        //string[] files = Directory.GetFiles("./", "*", SearchOption.AllDirectories);
        //for (int index = 0; index < files.Length; ++index)
        //{
        //    int fileIndex = fs.AddFileFromDisk(files[index], 0);
        //    if (fileIndex < 0)
        //    {
        //        Debug.LogWarning("AddFileFromDisk failed : " + files[index]);
        //    }
        //}

        //Debug.Log("Build VFS finished : " + outPath + " add files: " + fs.GetNumFiles());

        //fs.Close();
        //Directory.SetCurrentDirectory(currentDir);
        return true;
    }

    //private static bool InternalExtract(string input, string output)
    //{
    //    //如果该目录存在，则删除目录
    //    if (Directory.Exists(output))
    //    {
    //        Directory.Delete(output, true);
    //    }

    //    // 新建输出文件并进行编辑
    //    VirtualFileSystem fs = new VirtualFileSystem();
    //    if (!fs.Open(input, VirtualFileSystem.FileMode.fileModeRead))
    //    {
    //        Debug.LogError("Open VFS failed : " + input + " cannot open vfs file!");
    //        return false;
    //    }

    //    fs.ExtractAll(output, null);

    //    return true;
    //}

    //private static void Extract()
    //{
    //    string[] args = System.Environment.GetCommandLineArgs();
    //    if (args.Length < 12)
    //    {
    //        return;
    //    }
    //    string inPath = args[10];
    //    string outPath = args[11];

    //    if (!InternalExtract(inPath, outPath))
    //    {
    //        System.Environment.Exit(1);
    //    }
    //}
}