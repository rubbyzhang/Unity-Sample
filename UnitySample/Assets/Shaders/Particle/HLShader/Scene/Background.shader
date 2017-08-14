// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HL/Scene/Background" {
Properties {
	_MainTex ("Main Tex (RGB)", 2D) = "white" {}
	_Color ("Main Color", Color) = (.5, .5, .5, 1)
	_Fog ("Fog Color", Color) = (1, 1, 1, 0.1)
}

CGINCLUDE
		#include "UnityCG.cginc"
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma target 2.0

		fixed4 _Color;
		fixed4 _Fog;
		float4 _MainTex_ST;
		sampler2D _MainTex ;

		struct v2f {
			float4  pos : SV_POSITION;
			float2  uv : TEXCOORD0;
		};

		v2f vert (appdata_full v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos (v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

		fixed4 frag (v2f i) : COLOR
		{
			fixed3 texcolor = tex2D(_MainTex, i.uv).rgb;
			fixed4 c = fixed4(_Color.rgb * 2.0, 1.0);
			c.rgb *= texcolor;
			c.rgb = lerp(c.rgb, _Fog.rgb, _Fog.a);
			return c;
		}
ENDCG

SubShader {
	Tags { "Queue" = "Geometry+100"  "RenderType"="Opaque" "DepthMode"="true"}
	Lighting Off
	Cull Back
	Blend Off
	Fog {Mode Off}

    Pass {
		Tags { "LIGHTMODE"="Always" }
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
    }
}

//Fallback "VertexLit"
} 