// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "KTA/Transparent Colored"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "white" {}
		_ShadowColor ("ShadowColor" , Color) = (0.0, 0.0, 0.0, 0.5)
		_ShadowOffset ("ShadowOffset" , Float) = 0.05
	}
	
	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "AlphaTest"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
		}
		
		Cull Back
		Lighting Off
		ZWrite Off
		//ZTest LEqual
		Fog { Mode Off }
		//Offset -1, -1
		Blend SrcAlpha OneMinusSrcAlpha

		
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

		


			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _ShadowColor;
			float _ShadowOffset;
			
			v2f_img vert (appdata_img v)
			{
				v2f_img o;
				
				//v.vertex.x *= 1.1;
				//v.vertex.y *= 1.1;
				//v.vertex.x -= 0.5;
				//v.vertex.y -= 0.1;
				o.pos = UnityObjectToClipPos(v.vertex);
				//o.pos.x += 0.02;
				//o.pos.x += 0.02;
				o.pos.y -= _ProjectionParams.x * _ShadowOffset;

				
				o.uv = MultiplyUV( UNITY_MATRIX_TEXTURE0, v.texcoord );
				return o;
			}
			
			fixed4 frag (v2f_img i) : COLOR
			{	
				//#if UNITY_UV_STARTS_AT_TOP
					//if (_MainTex_ST.y < 0)
					        i.uv.y = 1-i.uv.y;
				//#endif
				fixed4 col = tex2D(_MainTex, i.uv);
				
				col.rgb = _ShadowColor.rgb;
				col.a *= _ShadowColor.a;
				
				
				return col;
			}
			ENDCG
		}

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
					fixed4 col = tex2D(_MainTex, i.texcoord) * i.color;
					return col;
				}
			ENDCG
		}
	}
}
