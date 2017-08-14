// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "KTA/AdditionTransparent"
{
	Properties
	{
		_MainTex ("Base", 2D) = "white" {}
		_Additional("Additional", Float) = 0
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
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
		ZWrite Off
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha

//		Pass
//		{
//			CGPROGRAM
//			#pragma vertex vert
//			#pragma fragment frag
//			
//			#include "UnityCG.cginc"
//
//		
//
//
//			sampler2D _MainTex;
//			float4 _ShadowColor;
//			float _ShadowOffset;
//			
//			v2f_img vert (appdata_img v)
//			{
//				v2f_img o;
//				
//				//v.vertex.x *= 1.1;
//				//v.vertex.y *= 1.1;
//				//v.vertex.x -= 0.5;
//				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
//				//o.pos.x += 0.02;
//				
//				//o.pos.x += 0.02;
//				o.pos.y -= _ShadowOffset;
//				o.uv = MultiplyUV( UNITY_MATRIX_TEXTURE0, v.texcoord );
//				return o;
//			}
//			
//			fixed4 frag (v2f_img i) : COLOR
//			{
//				fixed4 col = tex2D(_MainTex, i.uv);
//				
//				col.rgb = _ShadowColor.rgb;
//				col.a *= _ShadowColor.a;
//				
//				
//				return col;
//			}
//			ENDCG
//		}


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
				float _Additional;
				float _Cutoff;
				
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
					
					half3 addRgb = half3(_Additional,_Additional,_Additional);
					
					col.rgb += addRgb;
					
					return col;
				}
			ENDCG
		}
	}
}
