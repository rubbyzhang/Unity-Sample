// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "KTA/AdditionTransparentCutout"
{
	Properties
	{
		_MainTex ("Base", 2D) = "white" {}
		_MaskTex ("Noise", 2D) = "white" {}
		_MaskColor ("MaskColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		_MinMaskAlpha("MinMaskAlpha", Float) = 0
		_MaxMaskAlpha("MaxMaskAlpha", Float) = 1
		_Frequency("Frequency", Range(0,100)) = 10
	}
	
	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Cull Back
		Lighting Off
		ZWrite On
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				#include "UnityCG.cginc"
	
				struct appdata_t
				{
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};
	
				struct v2f
				{
					float4 vertex : SV_POSITION;
					half2 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};
	
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _MaskTex;
				float _Cutoff;
				
				float4 _MaskColor;
				float _MinMaskAlpha;
				float _MaxMaskAlpha;
				float _Frequency;
				
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.color = v.color;
					return o;
				}
				
				fixed4 frag (v2f i) : COLOR
				{
					fixed4 col = tex2D(_MainTex, i.texcoord);
					
					if (col.a < _Cutoff)
						discard;
						
					fixed4 mcol = tex2D(_MaskTex, i.texcoord);
						
					float a = lerp(_MinMaskAlpha, _MaxMaskAlpha,(sin(_Time.y*_Frequency) + 1)/2);
					
					col.rgb += ((mcol * _MaskColor).rgb * a);
					
					return col;
				}
			ENDCG
		}
	}
}
