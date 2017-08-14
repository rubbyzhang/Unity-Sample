// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BlueWar/NPRLitToonEnvFade"
{
	Properties
	{
		_Fade("Fade", Range(0, 1)) = 1.0
        _LightThreshold("Light Threshold", Range(0, 1)) = 0.5
        _LightSmoothness("Light Smoothness", Range(0, 1)) = 0.5
        _MainTex("Base (RGB)", 2D) = "white" {}
        _DecalTex("Decal (RGB)", 2D) = "black" {}
        DecalUV("DecalUV", Vector) = (1, 1, 1, 1) //center_xy[0,0]-[1,1], tile_zw,[0,+INF] 
        _ToonMap("ToonMap (RGB)", 2D) = "white" {}
        _ShadingMask("ShadingMask (RGB)", 2D) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" }
		
		LOD 100

		Pass
		{
			Name "WriteZ"
			Tags{ "LightMode" = "ForwardBase" }

			Cull back
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha
			Fog{ Mode Off }
			Lighting Off

			CGPROGRAM
			// compile directives
			#pragma vertex MainVS
			#pragma fragment MainPS
			#include "UnityCG.cginc"

			// vertex-to-fragment interpolation data
			// no lightmaps:
			struct VSOut
			{
				float4 pos : SV_POSITION;
			};


			// vertex shader
			VSOut MainVS(appdata_full v)
			{
				VSOut result;
				UNITY_INITIALIZE_OUTPUT(VSOut,result);
				result.pos = UnityObjectToClipPos(v.vertex);
				return result;
			}

			// fragment shader
			fixed4 MainPS(VSOut IN) : SV_Target
			{
				return fixed4(0,0,0,0);
			}
			ENDCG
		}

        Pass 
        {
        	NAME "FORWARD"

            Tags { "LightMode" = "ForwardBase" }

            Cull Back ZTest LEqual Blend SrcAlpha OneMinusSrcAlpha

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
            #pragma multi_compile _ USE_DECAL
			#pragma multi_compile _ USE_LOCALLIGHT
			#define USE_ALPHABLEND
            #pragma vertex   NPRToonCharacterStandardVS
            #pragma fragment NPRToonCharacterStandardPS
            #include "NPRToonStandard.cginc"
            ENDCG
        }
	}
	FallBack "Diffuse"
}
