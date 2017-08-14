// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/ColorChange"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Hue("Hue", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		ZTest Always ZWrite off Cull off

		Fog { mode off }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float _Hue;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			half3 RGB2HSV(half3 c)  
			{  
			    half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);  
			    half4 p = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));  
			    half4 q = lerp(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));  
			  
			    half d = q.x - min(q.w, q.y);  
			    half e = 1.0e-10;  
			    return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);  
			}  

			half3 HSV2RGB(half3 c)  
			{  
			    half4 K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);  
			    half3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);  
			    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);  
			}  

		    half3 shift_col(half3 RGB, half3 shift)
		    {
			    half3 RESULT = half3(RGB);

			    float VSU = shift.z*shift.y*cos(shift.x);
			    float VSW = shift.z*shift.y*sin(shift.x);
			        
			      RESULT.x = (.299*shift.z+.701*VSU+.168*VSW)*RGB.x
			          + (.587*shift.z-.587*VSU+.330*VSW)*RGB.y
			          + (.114*shift.z-.114*VSU-.497*VSW)*RGB.z;
			        
			      RESULT.y = (.299*shift.z-.299*VSU-.328*VSW)*RGB.x
			          + (.587*shift.z+.413*VSU+.035*VSW)*RGB.y
			          + (.114*shift.z-.114*VSU+.292*VSW)*RGB.z;
			        
			      RESULT.z = (.299*shift.z-.3*VSU+1.25*VSW)*RGB.x
			          + (.587*shift.z-.588*VSU-1.05*VSW)*RGB.y
			          + (.114*shift.z+.886*VSU-.203*VSW)*RGB.z;
			        
			    return (RESULT);
		    }
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				half4 col = tex2D(_MainTex, i.uv);

				/*
				half3 hsv = RGB2HSV(col.rgb);
				hsv.x = _Hue;
				half3 rgb = HSV2RGB(hsv.rgb);
				*/

				return fixed4(shift_col(col.rgb, half3(_Hue, 1, 1)), col.a);
			}
			ENDCG
		}
	}
}
