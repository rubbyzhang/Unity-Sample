// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "KTA/FX1/AlphaBlend" {
	Properties {
		_MainTex ("Base", 2D) = "white" {}
		_TintColor ("TintColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_UOffsetSpeed ("UOffsetSpeed", Float) = 0
		_VOffsetSpeed ("YOffsetSpeed", Float) = 0
		_UVRotateSpeed ("UVRotateSpeed", Float) = 0
		_Intensity("Intensity", Float) = 1

		_RootPos("RootPos",Vector) = (0,0,0,1)
		[MaterialToggle] _isMirror("isMirror", Float) = 0
		_Normal("Normal",Vector) = (0,0,0,1)
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", float) = 0
	}
	
	CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_ST;
		
		fixed4 _TintColor;
		float _UOffsetSpeed;
		float _VOffsetSpeed;
		float _UVRotateSpeed;
		float _Intensity;

		float4 _RootPos;
		float4 _Normal;
		float _isMirror;
						
		struct v2f {
			half4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			float4 color : COLOR;
		};


		v2f vert(appdata_full v) {
			v2f o;
			if (_isMirror > 0)
			{
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float f = dot(_Normal.xyz, (_RootPos - worldPos).xyz);
				if (f < 0)
				{
					_Normal = -_Normal;
				}
				_Normal.xyz = _Normal.xyz * dot(_Normal.xyz, (_RootPos - worldPos).xyz);
				worldPos.xyz = worldPos.xyz + 2 * _Normal.xyz;
				v.vertex = mul(unity_WorldToObject, worldPos);
			}
			o.pos = UnityObjectToClipPos (v.vertex);
			o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			
			float2 finaluv =  o.uv.xy - float2(0.5, 0.5);
			float rotation = 3.14159 * 2 * _Time.z * _UVRotateSpeed;
			finaluv = float2(finaluv.x * cos(rotation) - finaluv.y * sin(rotation), finaluv.x * sin(rotation) + finaluv.y * cos(rotation) );
			finaluv += float2(0.5, 0.5);
			
			finaluv.x += _Time.z * _UOffsetSpeed;
			finaluv.y += _Time.z * _VOffsetSpeed;
			
			o.uv.xy = finaluv;
			o.color = v.color;	
			
			return o; 
		}
		
		fixed4 frag( v2f i ) : COLOR {
			
			fixed4 ocolor = tex2D (_MainTex, i.uv.xy );
			
			ocolor = ocolor * _TintColor;
			
			ocolor *= i.color;
			
			ocolor *= _Intensity;
			
			return ocolor;
		}
	
	ENDCG
	
	SubShader {
		Tags { "RenderType" = "Transparent" "Reflection" = "RenderReflectionTransparentAdd" "Queue" = "Transparent"}
		Cull[_CullMode]
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		
	Pass {
		CGPROGRAM
		
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest 
		
		ENDCG
		}
	}
	
	
	FallBack Off
}
