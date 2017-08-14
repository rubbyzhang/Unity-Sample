// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HL/Scene/Basic" {
Properties {
	_Color ("Main Color", Color) = (.5, .5, .5, 1)
	_MainTex ("Main Tex (RGB)", 2D) = "white" {}
}

CGINCLUDE
		#include "UnityCG.cginc"
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma target 2.0

		fixed4 _Color;
		sampler2D _MainTex ;
		float4 _MainTex_ST;

		struct appdata
		{
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4  pos : SV_POSITION;
			float2  uv : TEXCOORD0;
		};

		v2f vert (appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos (v.vertex);
			o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
			return o;
		}

		fixed4 frag (v2f i) : COLOR0
		{
			fixed3 lay1 = tex2D(_MainTex, i.uv).rgb;
			fixed4 c = fixed4(_Color.rgb * 2.0, 1.0);
			c.rgb *= lay1;
			return c;
		}

ENDCG

SubShader {
	Tags { "Queue" = "Geometry-100"  "RenderType"="Opaque" "DepthMode"="true"}
	Lighting Off
	Cull Back
	Blend Off

	Pass {
		Tags { "LIGHTMODE"="VertexLMRGBM" }
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
    }

	Pass {
		Tags { "LIGHTMODE"="VertexLM" }
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
    }

	Pass {
		Tags { "LIGHTMODE"="Vertex" }
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
    }
}

//Fallback "VertexLit"
} 