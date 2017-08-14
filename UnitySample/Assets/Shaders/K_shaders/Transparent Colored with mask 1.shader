// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Transparent Colored with mask 1" 
{
  Properties 
  {
    _MainTex ("Base (RGB), Alpha (A)", 2D) = "white" {}
    _AlphaTex ("Base (RGB), Alpha (A)", 2D) = "white" {}
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
		
		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Offset -1, -1
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
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
	
			struct v2f
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 worldPos : TEXCOORD1;
			};
	
			sampler2D _MainTex;
			sampler2D _AlphaTex;
			
			float4 _ClipRange0 = float4(0.5, 0.1, 1.0, 1.0);
			float2 _ClipArgs0 = float2(1000.0, 1000.0);
				
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.worldPos = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
				return o;
			}

			half4 frag (v2f IN) : COLOR
			{
				// Softness factor
				float2 factor = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipArgs0;
							
				// Sample the texture
				half4 col = tex2D(_MainTex, IN.texcoord) * IN.color;
				col.a *= clamp( min(factor.x, factor.y), 0.0, 1.0);
				
				fixed4 maskcol = tex2D(_AlphaTex, IN.texcoord) * IN.color;
				if(maskcol.a < 0.1)
					col.a = 0;
				return col;
			}
			ENDCG
		}
	}
  FallBack "Diffuse"
}
