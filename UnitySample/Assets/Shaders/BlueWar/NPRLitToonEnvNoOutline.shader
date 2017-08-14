Shader "BlueWar/NPRLitToonEnvNoOutline"
{
    Properties
    {
        [Header(Shader Properties)]
            _LightThreshold("Light Threshold", Range(0, 1)) = 0.5
            _LightSmoothness("Light Smoothness", Range(0, 1)) = 0.5
            _GlossyMatcap("Glossy Matcap", 2D) = "" {}
            _MainTex("Base (RGB)", 2D) = "white" {}
            _DecalTex("Decal (RGB)", 2D) = "black" {}
            DecalUV("DecalUV", Vector) = (1, 1, 1, 1) //center_xy[0,0]-[1,1], tile_zw,[0,+INF]
            _ToonMap("ToonMap (RGB)", 2D) = "white" {}
            _ShadingMask("ShadingMask (RGB)", 2D) = "white" {}
            SpecularPower("SpecularPower", Float) = 1.0
            SpecularFactor("SpecularFactor", Range(0, 1)) = 1.0
            RimGeneral("Rim General", Range(0, 1)) = 0.5
            RimPower("Rim Power", Float) = 1

        [Header(Shader Feature Lists)]
            [Toggle(USE_DECAL)] _UseDecal("Use Decal?", Float) = 0
            [Toggle(USE_SPECULARLIGHTING)] _UseSpecularLighting("Use Specular Lighting?", Float) = 1
            [Toggle(USE_RIMLIGHTING)] _UseRimLighting("Use Rim Lighting?", Float) = 1
            [Toggle(USE_GLOSSYREFLECTION)] _UseGlossyReflection("Use Glossy Reflection?", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry+401" }

        LOD 150

        // ---- forward rendering base pass:
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Cull Back ZTest LEqual Blend off ZWrite on

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
            #pragma shader_feature _ USE_GLOSSYREFLECTION
            #pragma shader_feature USE_RIMLIGHTING _
            #pragma shader_feature USE_SPECULARLIGHTING _

            #pragma multi_compile_fwdbase
            #pragma multi_compile _ USE_LOCALLIGHT
			#pragma multi_compile NOTHINGSPECIAL VERTEXLIGHT_ON

			#pragma vertex   NPRToonCharacterStandardVS
            #pragma fragment NPRToonCharacterStandardPS
            #include "NPRToonStandard.cginc"
            ENDCG
        }
    }

    // for battle
    SubShader
    {
        Tags { "RenderType" = "Opaquer" "Queue" = "Geometry+401" }

        LOD 100

		USEPASS "BlueWar/NPRLitToonEnv/FORWARD"
    }

    FallBack "Diffuse"

    CustomEditor "ToonMaterialEditor"
}