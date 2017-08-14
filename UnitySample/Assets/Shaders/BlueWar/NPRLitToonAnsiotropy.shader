Shader "BlueWar/NPRLitToonAnisotropy"
{
    Properties
    {
        [HideInInspector]_Fade("Fade", Range(0, 1)) = 1.0

        [Header(Shader Properties)]
            _LightThreshold("Light Threshold", Range(0, 1)) = 0.5
            _LightSmoothness("Light Smoothness", Range(0, 1)) = 0.5
            _MainTex("Base (RGB)", 2D) = "white" {}
            _ToonMap("ToonMap (RGB)", 2D) = "white" {}
            _ShadingMask("ShadingMask (RGB)", 2D) = "white" {}
            _AnisotropyShift1("Primary Anisotropy Shift", Range(-1,1)) = 0.0
            _AnisotropyShift2("Secondary Anisotropy Shift", Range(-1,1)) = 0.0
            _AnisotropyPower1("Primary Anisotropy Power", Range(0, 1000)) = 100
            _AnisotropyPower2("Secondary Anisotropy Power", Range(0, 1000)) = 200
            _SpecularColor1("Primary Specular Color", Color) = (0.0, 0.0, 0.0, 0.0)
            _SpecularColor2("Secondary Specular Color", Color) = (0.0, 0.0, 0.0, 0.0)
            RimGeneral("Rim General", Range(0, 1)) = 0.5
            RimPower("Rim Power", Float) = 1

        [Header(Shader Feature Lists)]
            [Toggle(USE_RIMLIGHTING)] _UseRimLighting("Use Rim Lighting?", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry+401" }

        LOD 150

        // render front face of anisotropy surface
        Pass
        {
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

            #pragma shader_feature USE_RIMLIGHTING _

            #pragma multi_compile_fwdbase            
            #pragma multi_compile _ USE_LOCALLIGHT            
			#pragma multi_compile NOTHINGSPECIAL VERTEXLIGHT_ON

            #define FULL_ANISOTROPYLIGHTING
			#pragma vertex   NPRToonCharacterAnisotropyVS
            #pragma fragment NPRToonCharacterAnisotropyPS
            #include "NPRToonStandard.cginc"
            ENDCG
        }

        // render back face of anisotropy surface
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            Cull Front ZTest LEqual Blend off ZWrite on

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

            #pragma shader_feature USE_RIMLIGHTING _

            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #pragma multi_compile _ USE_LOCALLIGHT
            #pragma multi_compile NOTHINGSPECIAL VERTEXLIGHT_ON

            #define INVERT_NORMAL
            #define FULL_ANISOTROPYLIGHTING
			#pragma vertex   NPRToonCharacterAnisotropyVS
            #pragma fragment NPRToonCharacterAnisotropyPS
            #include "NPRToonStandard.cginc"
            ENDCG
        }
    }

    SubShader
    {
    	Tags { "RenderType" = "Opaque" "Queue" = "Geometry+401" }

    	LOD 100

    	Pass
    	{
            Tags { "LightMode" = "ForwardBase" }

            Cull off ZTest LEqual Blend off ZWrite on

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

            #pragma multi_compile_fwdbase
            #pragma multi_compile _ USE_LOCALLIGHT

			#pragma vertex   NPRToonCharacterAnisotropyVS
            #pragma fragment NPRToonCharacterAnisotropyPS
            #include "NPRToonStandard.cginc"
            ENDCG
        }
    }

    FallBack "Diffuse"

    CustomEditor "ToonMaterialEditor"
}