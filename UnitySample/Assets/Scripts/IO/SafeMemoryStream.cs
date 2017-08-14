using System;
using UnityEngine;
using System.Collections;
using System.IO;


/// <summary>
/// No exception memorystream
/// </summary>
public class SafeMemoryStream
{
    private readonly FileStream mMemoryStream;

    public static SafeStream Open(MemoryStream memoryStream)
    {
        if (null == memoryStream)
        {
            return null;
        }

        return new SafeStream(memoryStream);
    }

    public static SafeStream Open(byte[] buffer)
    {
        if (null == buffer)
        {
            return null;
        }

        // MemoryStream is not writable
        return Open(new MemoryStream(buffer, false));
    }
}