Shader "BlueWar/NPRLitToonEnvAlphaBlendedNoOutline"
{
    Properties
    {
        [HideInInspector]_Fade("Fade", Range(0, 1)) = 1.0

        [Header(Shader Properties)]
            _LightThreshold("Light Threshold", Range(0, 1)) = 0.5
            _LightSmoothness("Light Smoothness", Range(0, 1)) = 0.5
            _MainTex("Base (RGB)", 2D) = "white" {}
            _DecalTex("Decal (RGB)", 2D) = "black" {}
            DecalUV("DecalUV", Vector) = (1, 1, 1, 1) //center_xy[0,0]-[1,1], tile_zw,[0,+INF]
            _ToonMap("ToonMap (RGB)", 2D) = "white" {}
            _ShadingMask("ShadingMask (RGB)", 2D) = "white" {}
            SpecularPower("SpecularPower", Float) = 1.0
            SpecularFactor("SpecularFactor", Range(0, 1)) = 1.0
            RimGeneral("Rim General", Range(0, 1)) = 0.5
            RimPower("Rim Power", Float) = 1

        [Header(Render State)]
            [Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 0
            [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 2

        [Header(Shader Feature Lists)]
            [Toggle(USE_DECAL)] _UseDecal("Use Decal?", Float) = 0
            [Toggle(USE_SPECULARLIGHTING)] _UseSpecularLighting("Use Specular Lighting?", Float) = 1
            [Toggle(USE_RIMLIGHTING)] _UseRimLighting("Use Rim Lighting?", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        LOD 150

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}

            Cull [_Cull] ZTest LEqual Blend SrcAlpha OneMinusSrcAlpha ZWrite [_ZWrite] BlendOp Add,Max

            Stencil {
                Ref 128
                WriteMask 128
                Comp Always
                Pass Replace
                ZFail Keep
            }

            CGPROGRAM
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 3.0

            #pragma shader_feature _ USE_DECAL
            #pragma shader_feature USE_RIMLIGHTING _
            #pragma shader_feature USE_SPECULARLIGHTING _

            #pragma multi_compile_fwdbase
            #pragma multi_compile _ USE_LOCALLIGHT
			#pragma multi_compile NOTHINGSPECIAL VERTEXLIGHT_ON

            #define USE_ALPHABLEND
            #pragma vertex   NPRToonCharacterStandardVS
            #pragma fragment NPRToonCharacterStandardPS
            #include "NPRToonStandard.cginc"
            ENDCG
        }
    }

    // for battle
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        LOD 100

		USEPASS "BlueWar/NPRLitToonEnvAlphaBlended/FORWARD"
    }

    CustomEditor "ToonMaterialEditor"
}