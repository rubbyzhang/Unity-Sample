Shader "Custom/UnlitDistance"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,0.5)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Cutoff("Cut Off", Range(0, 1)) = 0.1
		_FogIntensity ("Fog Intensity", Range(0.01,1.00)) = 0.01
		_FogOffset("Fog Offset", Range(-1,1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed  _Cutoff;
			fixed  _FogIntensity;
			fixed  _FogOffset;
			fixed4 _BloomPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				float3 dir = mul(unity_ObjectToWorld, v.vertex);
				o.uv.zw = (normalize(dir).y + _FogOffset) / _FogIntensity;

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				
				clip (col.a - _Cutoff);
				
				col = fixed4(col.rgb * _Color.rgb, _Color.a);
				half fog = 1 - saturate((i.uv.z));
				col.rgb = lerp(col.rgb, unity_FogColor, fog * fog) * _BloomPower.x; // blend with fog
				
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
