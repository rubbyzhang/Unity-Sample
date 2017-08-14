using UnityEngine;
using System.Collections;
using Celf;

public class ResourceServiceExport 
{
    public static void UnloadUnusedAssets()
    {
        ResourceService.Instance.UnloadUnusedAssets();
    }

    public static void GC()
    {
        ResourceService.Instance.GC();
    }

    //临时载入角色接口(请不要调用)
    public static GameObject LoadCharacter()
    {
        GameObject obj = ResourceService.Instance.LoadCharacter("prefabs/Player");
        if (obj != null)
        {
            return GameObject.Instantiate(obj);
        }
        return null;
    }

    public static GameObject LoadTeamFlag(string flagName)
    {
        GameObject obj = ResourceService.Instance.LoadGameObject("common/"+ flagName);
        if (obj != null)
        {
            return GameObject.Instantiate(obj);
        }
        return null;
    }
}
