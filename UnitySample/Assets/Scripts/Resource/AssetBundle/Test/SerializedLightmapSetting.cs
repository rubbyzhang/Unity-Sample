//using UnityEngine;

//[ExecuteInEditMode]
//public class SerializedLightmapSetting : MonoBehaviour
//{
//    /*[HideInInspector]*/ public Texture2D[] LightMapColor;
///*    [HideInInspector]*/ public Texture2D[] ShadowMask;
//    /*[HideInInspector] */public Texture2D[] LightMapDir;

//    [HideInInspector]
//    public LightmapsMode mLightMode;

//#if UNITY_EDITOR
//    public void OnEnable()
//    {
//        //Debug.Log("[SerializedLightmapSetting] hook");
//        UnityEditor.Lightmapping.completed += LoadLightmaps;
//    }
//    public void OnDisable()
//    {
//        //Debug.Log("[SerializedLightmapSetting] unhook");
//        UnityEditor.Lightmapping.completed -= LoadLightmaps;
//    }

//    public void LoadLightmaps()
//    {
//        mLightMode = LightmapSettings.lightmapsMode;
//        LightMapColor = null;
//        ShadowMask = null;

//        if (LightmapSettings.lightmaps != null && LightmapSettings.lightmaps.Length > 0)
//        {
//            int length = LightmapSettings.lightmaps.Length;
//            LightMapColor = new Texture2D[length];
//            ShadowMask = new Texture2D[length];

//            for (int i = 0; i < length; i++)
//            {
//                LightMapColor[i] = LightmapSettings.lightmaps[i].lightmapColor;
//                ShadowMask[i] = LightmapSettings.lightmaps[i].shadowMask;
//            }
//        }
//    }
//#endif

//    public void Start()
//    {
//        if (Application.isPlaying)
//        {
//            //LightmapSettings.lightmapsMode = mLightMode;

//            //int l1 = (LightMapColor == null) ? 0 : LightMapColor.Length;
//            //int l2 = (ShadowMask == null) ? 0 : ShadowMask.Length;
//            //int l = (l1 < l2) ? l2 : l1;

//            //LightmapData[] lightmaps = null;
//            //if (l > 0)
//            //{
//            //    lightmaps = new LightmapData[l];
//            //    for (int i = 0; i < l; i++)
//            //    {
//            //        lightmaps[i] = new LightmapData();
//            //        if (i < l1)
//            //            lightmaps[i].lightmapColor = LightMapColor[i];
//            //        if (i < l2)
//            //            lightmaps[i].shadowMask = ShadowMask[i];
//            //    }
//            //}

//            //LightmapSettings.lightmaps = lightmaps;

//            //Destroy(this);
//        }
//    }

//}