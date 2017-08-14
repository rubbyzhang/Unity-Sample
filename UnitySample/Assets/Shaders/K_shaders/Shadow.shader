// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "KTA/Shadow"
{
	Properties
	{
		_MainTex ("Base", 2D) = "white" {}
		_ShadowColor ("ShadowColor" , Color) = (0.0, 0.0, 0.0, 0.5)
	}
	
	SubShader
	{
		LOD 100
		
		Tags
		{
			"Queue" = "Geometry+100"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
		}
		
		Cull Off
		Lighting Off
		ZWrite Off
		ZTest LEqual
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				#include "UnityCG.cginc"
	
	
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _ShadowColor;
				
				struct v2f 
				{
					half4 pos : SV_POSITION;
					half2 uv : TEXCOORD0;
					float4 color : COLOR;
				};
				
				v2f vert (appdata_full v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.color = v.color;
					return o;
				}
				
				fixed4 frag (v2f i) : COLOR
				{
					fixed4 col = tex2D(_MainTex, i.uv);
					
					col.rgb = _ShadowColor.rgb;
					col.a *= _ShadowColor.a;
					
					col *= i.color;
					
					return col;
				}
			ENDCG
		}
	}
}
