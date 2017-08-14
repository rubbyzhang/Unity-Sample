// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HY/Volumetric Fog"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_Intensity ("Intensity", float) = 1
		_MainTex ("Main Tex", 2D) = "white" {}
		_USpeed ("USpeed", Float) = 0
		_VSpeed ("VSpeed", Float) = 0
		_AddTex ("Mask Tex", 2D) = "white" {}
	}

		CGINCLUDE

		ENDCG

		SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent"}
		Pass
		{
			Tags { "LIGHTMODE" = "Always" }
			Lighting Off
			Fog { Mode Off }
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			ZWrite Off

			CGPROGRAM
			//#include "../HLInclude.cginc"
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			//#pragma target 2.0

			//#define DISABLE
			//#define EXP2FOG
			float4 _Color;
			float _Intensity;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _AddTex;
			float4 _AddTex_ST;
			float _USpeed;
			float _VSpeed;

			inline float2 Calculate_UVAnim(float2 uv, float uSpeed, float vSpeed)
			{
				float time = _Time.z;
				float absUOffsetSpeed = abs(uSpeed);
				float absVOffsetSpeed = abs(vSpeed);

				if (absUOffsetSpeed > 0)
				{
					uv.x += frac(time * uSpeed);
				}

				if (absVOffsetSpeed > 0)
				{
					uv.y += frac(time * vSpeed);
				}

				return uv;
			}

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : POSITION;
                float2 uv[2] : TEXCOORD0;
				fixed4 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.color = i.color * _Color;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv[0] = TRANSFORM_TEX(i.uv, _MainTex);
				o.uv[1] = TRANSFORM_TEX(i.uv, _AddTex);

				o.uv[0] = Calculate_UVAnim(o.uv[0], _USpeed, _VSpeed);

				return o;
			}

			fixed4 frag(v2f i) : COLOR0
			{
				fixed4 color = i.color * _Intensity;
				fixed4 mainColor = tex2D(_MainTex, i.uv[0]);
				fixed4 maskColor = tex2D(_AddTex, i.uv[1]);
				mainColor *= maskColor;
				color.a *= mainColor.a;
				return color;
			}
	
			ENDCG
		} 
	}

	Fallback "Diffuse"
}