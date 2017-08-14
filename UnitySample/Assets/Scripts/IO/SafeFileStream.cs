using System;
using System.IO;


/// <summary>
/// No exception filestream
/// </summary>
public class SafeFileStream
{
    public static SafeStream Open(string path, FileMode mode)
    {
        return Open(path, mode, mode == FileMode.Append ? FileAccess.Write : FileAccess.ReadWrite, FileShare.None);
    }

    public static SafeStream Open(string path, FileMode mode, FileAccess access)
    {
        return Open(path, mode, access, FileShare.None);
    }

    public static SafeStream Open(string path, FileMode mode, FileAccess access, FileShare share)
    {
        try
        {
            FileStream fs = File.Open(path, mode, access, share);
            return new SafeStream(fs);
        }
        catch (Exception)
        {
            return null;
        }
    }

    /// <summary>
    /// Opens an existing file for reading.
    /// </summary>
    /// 
    public static SafeStream OpenRead(string path)
    {
        return Open(path, FileMode.Open, FileAccess.Read, FileShare.Read);
    }

    /// <summary>
    /// Opens an existing file for writing.
    /// </summary>
    /// 
    public static SafeStream OpenWrite(string path)
    {
        return Open(path, FileMode.OpenOrCreate, FileAccess.Write, FileShare.None);
    }

    /// <summary>
    /// Opens an existing file for editing.
    /// </summary>
    /// 
    public static SafeStream OpenEdit(string path)
    {
        return Open(path, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None);
    }
}