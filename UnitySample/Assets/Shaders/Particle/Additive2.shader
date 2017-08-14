// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "KTA/FX2/Additive" {
	Properties {
		_MainTex ("Base", 2D) = "white" {}
		_NoiseTex ("Noise", 2D) = "white" {}
		_TintColor ("TintColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_UOffsetSpeed ("XOffsetSpeed", Float) = 0
		_VOffsetSpeed ("YOffsetSpeed", Float) = 0
		_UVRotateSpeed ("UVRotateSpeed", Float) = 0
		_NUOffsetSpeed ("NXOffsetSpeed", Float) = 0
		_NVOffsetSpeed ("NYOffsetSpeed", Float) = 0
		_NUVRotateSpeed ("NUVRotateSpeed", Float) = 0
		_MainIntensity("MainIntensity", Float) = 1
	}
	
	CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		sampler2D _NoiseTex;
		float4 _NoiseTex_ST;
		fixed4 _TintColor;
		float _UOffsetSpeed;
		float _VOffsetSpeed;
		float _UVRotateSpeed;
		float _NUOffsetSpeed;
		float _NVOffsetSpeed;
		float _NUVRotateSpeed;
		float _MainIntensity;
		
		half4 _MainTex_ST;
						
		struct v2f {
			half4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 nuv : TEXCOORD1;
			float4 color : COLOR;
		};

		v2f vert(appdata_full v) {
			v2f o;
			o.pos = UnityObjectToClipPos (v.vertex);
			o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.nuv.xy = TRANSFORM_TEX(v.texcoord, _NoiseTex);
			
			float2 finaluv =  o.uv.xy - float2(0.5, 0.5);
			float rotation = 3.14159 * 2 * _Time.z * _UVRotateSpeed;
			finaluv = float2(finaluv.x * cos(rotation) - finaluv.y * sin(rotation), finaluv.x * sin(rotation) + finaluv.y * cos(rotation) );
			finaluv += float2(0.5, 0.5);
			
			finaluv.x += _Time.z * _UOffsetSpeed;
			finaluv.y += _Time.z * _VOffsetSpeed;
			
			o.uv.xy = finaluv;
			
			finaluv =  o.nuv.xy - float2(0.5, 0.5);
			rotation = 3.14159 * 2 * _Time.z * _NUVRotateSpeed;
			finaluv = float2(finaluv.x * cos(rotation) - finaluv.y * sin(rotation), finaluv.x * sin(rotation) + finaluv.y * cos(rotation) );
			finaluv += float2(0.5, 0.5);
			
			finaluv.x += _Time.z * _NUOffsetSpeed;
			finaluv.y += _Time.z * _NVOffsetSpeed;
			
			o.nuv.xy = finaluv;
			
			o.color = v.color;	
			
			return o; 
		}
		
		fixed4 frag( v2f i ) : COLOR {
			
			fixed4 ocolor = tex2D (_MainTex, i.uv.xy )* _TintColor;
			fixed4 ncolor = tex2D (_NoiseTex, i.nuv.xy );
			
			ocolor.rgb = ocolor.rgb  * ncolor.rgb * _MainIntensity;
			ocolor.a *= ncolor.a;
			//ocolor = (ocolor) * _TintColor;
			
			ocolor *= i.color;
			
			return ocolor;
		}
	
	ENDCG
	
	SubShader {
		Tags { "RenderType" = "Transparent" "Reflection" = "RenderReflectionTransparentAdd" "Queue" = "Transparent"}
		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend SrcAlpha One
		
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
