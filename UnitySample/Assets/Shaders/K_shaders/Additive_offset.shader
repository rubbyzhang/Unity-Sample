// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "KTA/FX1/Additive_offset" {
	Properties {
		_MainTex ("Base", 2D) = "white" {}
		_TintColor ("TintColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_Offset("Offset", Vector) = (0.0, 0.0, 0.0, 0.0)
	}
	
	CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_ST;
		
		fixed4 _TintColor;
		fixed4 _Offset;

		struct v2f {
			half4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			float4 color : COLOR;
		};


		v2f vert(appdata_full v) {
			v2f o;
			o.pos = UnityObjectToClipPos (v.vertex) + _Offset;
			o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.color = v.color;	
			
			return o; 
		}
		
		fixed4 frag( v2f i ) : COLOR {
			return 2.0f * _TintColor * i.color * tex2D (_MainTex, i.uv.xy );
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
