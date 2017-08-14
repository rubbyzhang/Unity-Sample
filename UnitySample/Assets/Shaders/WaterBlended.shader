Shader "BlueWar/Ocean/Water Blended" {
	Properties {
		[KeywordEnum(Simple, Medium, High)] _WaterMode("Water Mode", Float) = 0

		[Header(Normal Texture And Scales)]
		[NoScaleOffset]_WavesTexture("Waves Texture", 2D) = "white" {}
		_SmallWavesTiling("Small Waves Tiling", Float) = 1
		_LargeWavesTiling("Large Waves Tiling", Float) = 0.3
		_SmallWaveRefraction("Small Wave Refraction", Range(0, 3)) = 2.2
		_LargeWaveRefraction("Large Wave Refraction", Range(0, 3)) = 1.5

		[NoScaleOffset]_RampTex("R: Diffuse Wrap, G: Specular Wrap, B: Fresnel Wrap", 2D) = "white" {}
		
		[Header(Shore Line And Ground Tex)]
		[Toggle] _UseGroundTex("Use Ground Tex?", Float) = 0
		[NoScaleOffset]_GroundTex("Ground Tex", 2D) = "white" {}
		_GroundIntensity("Ground Intensity", Range(0, 2)) = 0.5
		[Toggle] _UseShoreLine("Use Shore Line?", Float) = 0
		_ShoreLineTex("ShoreLine Foam", 2D) = "white" {}
		_ShoreLineIntensity("ShoreLine Intensity", Float) = 2

		[Header(Speed)]
		_SpeedX("Speed X", Float) = 0.0
		_SpeedZ("Speed Z", Float) = 1.0
		_WaveSpeed("Wave Speed", Float) = 0.4

		[Header(Reflect Sky)]
		
		[NoScaleOffset]_Cubemap("Environment Cubemap", Cube) = "_Skybox" {}
		_SunIntensity("Sun Intensity", Range(0, 1)) = 0.5
		_ReflDistort("Reflection Distort", Range(0, 0.5)) = 0.1
		_ReflAmount("Reflection Intensity", Range(0, 1)) = 1

		[Header(Diffuse)]
		_LightWaterColor("Light Water Color (A: alpha)", Color) = (1, 1, 1 , 1)
		_DeepWaterColor("Deep Water Color",Color) = (0, 0, 0, 1)

		[Header(Specular)]
		_Specular("Specular Color", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(0.1, 100)) = 4

		[Header(Reflection)]
		_ReflStart("Refl Start", Range(0, 1)) = 1
		_ReflRange("Refl Range", Range(0, 1)) = 0
		_ReflColor("Refl Color", Color) = (1, 0, 0, 0)

		[Header(Fog)]
		[KeywordEnum(NoFog, Scene, Camera)] _FogMode("Fog Mode", Float) = 0
	}
	SubShader{
		Tags { "Queue" = "Transparent-100" "RenderType" = "Transparent" "IgnoreProjector" = "True" }

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#include "WaterCommonCG.cginc"

			#pragma multi_compile_fwdbase
			#pragma multi_compile _WATERMODE_SIMPLE _WATERMODE_MEDIUM _WATERMODE_HIGH
			#pragma multi_compile _FOGMODE_NOFOG _FOGMODE_SCENE _FOGMODE_CAMERA
			#pragma multi_compile __ _BLEND

			#pragma shader_feature _USEGROUNDTEX_ON
			#pragma shader_feature _USESHORELINE_ON

			#pragma vertex water_vert
			#pragma fragment water_frag

			ENDCG
		}
	}
	FallBack "Diffuse"
}
