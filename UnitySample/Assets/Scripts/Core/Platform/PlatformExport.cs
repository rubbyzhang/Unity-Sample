using UnityEngine;

public class PlatformExport
{
    public static int GetRuntimePlatform()
    {
        return (int) Application.platform;
    }
}