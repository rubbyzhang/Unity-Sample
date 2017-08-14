using System;
using UnityEngine;
using System.Collections;
using System.ComponentModel;
using System.IO;

public class VFSResource
{
    /// <summary>
    /// 添加一个文件到VFS文件中
    /// </summary>
    /// <param name="rootPath">VFS文件路径</param>
    /// <param name="filePath">指定被添加的文件路径</param>
    /// <param name="bw">VFS文件的流</param>
    public static void AddFileToFile(string rootPath, string filePath, BinaryWriter bw)
    {
        if (File.Exists(filePath))
        {
            Uri uri1 = new Uri(filePath);
            Uri uri2 = new Uri(rootPath);
            string relativePath = uri2.MakeRelativeUri(uri1).ToString();

            byte[] fileBytes = File.ReadAllBytes(filePath);
            bw.Write(relativePath);
            bw.Write(fileBytes.Length);
            bw.Write(fileBytes);

            Debug.Log("Add File:  " + relativePath);
        }
    }

    public static void AddDirToFile(string dirPath, string outputPath)
    {
        //创建目录
        string ouputDir = Path.GetDirectoryName(outputPath);
        if (ouputDir != null)
        {
            Directory.CreateDirectory(ouputDir);
        }

        FileStream fs = new FileStream(outputPath, FileMode.Create);
        BinaryWriter bw = new BinaryWriter(fs);
        string[] fileList = Directory.GetFiles(dirPath, "*.*", SearchOption.AllDirectories);

        foreach (string filePath in fileList)
        {
            AddFileToFile(dirPath, filePath, bw);
        }

        bw.Close();
    }

    public static void ExtractFileFromMemory(string rootPath, BinaryReader br)
    {
        string filePath = Path.Combine(rootPath, br.ReadString());
        int fileLength = br.ReadInt32();
        string fileDir = Path.GetDirectoryName(filePath);
        if (fileDir != null)
        {
            Directory.CreateDirectory(fileDir);
        }

        FileStream fs = new FileStream(filePath, FileMode.Create);
        fs.Write(br.ReadBytes(fileLength), 0, fileLength);
        fs.Close();

        Debug.Log("Extract File:  " + filePath);
    }

    public static void ExtractDirFromMemory(string dirPath, byte[] bytes)
    {
        MemoryStream ms = new MemoryStream(bytes);
        BinaryReader br = new BinaryReader(ms);

        while (ms.Position < ms.Length)
        {
            ExtractFileFromMemory(dirPath, br);
        }

        br.Close();
    }
}