// UNITY_SHADER_NO_UPGRADE
Shader "BlueWar/Lightmapped/Opaque" 
{
    Properties 
    {
        _BaseColor      ("GENERAL.Base Color", Color)                         = (0.5,0.5,0.5,1)
        _MainTex        ("GENERAL.Albedo (RGB)", 2D)                          = "white" {}
        _LightmapTone1  ("GENERAL.Lightmap Tone", Color)                      = (1,1,1,1)
        _LightTex1      ("GENERAL.Lighting(RGB)", 2D)                         = "white" {}
        _LightmapTone2  ("GENERAL.Secondary Lightmap Tone", Color)            = (1,1,1,1)
        _LightTex2      ("GENERAL.Secondary Lighting(RGB)", 2D)               = "black" {}
        _ShadowTone     ("GENERAL.Shadow Tone", Color)                        = (0, 0, 0, 1)
        _MetalTex       ("METALNESS.Metal Mask", 2D)                          = "white" {}
        _MetallicTex    ("METALNESS.Metallic Map", 2D)                        = "" {}
        _NormalTex      ("NORMAL.Normal Map", 2D)                             = "bump" {}

        [HideInInspector]
        _ReflectionTex  ("REFLECTION.ReflectionTex (RGB)", 2D)                = "black" {}
        _ReflectionPower("REFLECTION.Reflection Power", Range(0, 1))          = 0.5
    }
    
    SubShader 
    {
        Tags { "RenderType"="Opaque" }

        LOD 200
        
        Pass 
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile LIGHTMAP_BLENDMODE_MULTIPLY LIGHTMAP_BLENDMODE_HARDLIGHT LIGHTMAP_BLENDMODE_LINEARLIGHT LIGHTMAP_BLENDMODE_PINLIGHT
            #pragma multi_compile REALTIMEREFLECTION_OFF REALTIMEREFLECTION_ON
            #pragma multi_compile FAKEMETAL_OFF FAKEMETAL_ON
            #pragma multi_compile NORMALMAP_ON NORMALMAP_OFF
            #pragma target 3.0
            #pragma multi_compile_fog 
            #pragma multi_compile_fwdbase nolightmap nodynlightmap novertexlight
            
            #include "./LightmappedCommon.cginc"

            ENDCG
        }
    }

    FallBack "Diffuse"
    CustomEditor "SkyBlueLightmapped"
}