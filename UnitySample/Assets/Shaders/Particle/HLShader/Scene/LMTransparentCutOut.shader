// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "HL/Scene/LMTransparentCutOut" {
Properties {
	_Color ("Main Color", Color) = (.5, .5, .5, 1)
	_MainTex ("Tex Alpha (RGBA)", 2D) = "white" {}
    _AlphaCutoff ("Alpha Cutoff", Range(0, 1)) = 0.1
}

CGINCLUDE
		#include "UnityCG.cginc"
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma target 2.0

		float _AlphaCutoff;
		fixed4 _Color;
		sampler2D _MainTex ;

		struct v2f {
			float4  pos : SV_POSITION;
			float2  uv[2] : TEXCOORD0;
		};

		float4 _MainTex_ST;
        fixed4 unity_LightmapST;
        // sampler2D unity_Lightmap;

		v2f vert (appdata_full v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos (v.vertex);
			o.uv[0] = TRANSFORM_TEX (v.texcoord, _MainTex);
            o.uv[1] = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
			return o;
		}

		fixed4 frag (v2f i) : COLOR
		{
			fixed4 lay1 = tex2D( _MainTex, i.uv[0].xy );
			fixed4 c = fixed4(_Color.rgb * 2, 1);
    		c *= lay1;
           	c.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv[1]));
			clip(c.a - _AlphaCutoff);
			return c;
		}

		fixed4 frag_noLM (v2f i) : COLOR
		{
			fixed4 lay1 = tex2D( _MainTex, i.uv[0].xy );
			fixed4 c = fixed4(_Color.rgb * 2, 1);
    		c *= lay1;
           	//c.rgb *= DecodeLightmap(tex2D(unity_Lightmap, i.uv[1]));
			clip(c.a - _AlphaCutoff);
			return c;
		}
ENDCG

SubShader {
	Tags { "Queue" = "Geometry-50"  "RenderType"="TransparentCutout" }
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
		#pragma fragment frag_noLM
		ENDCG
    }
}

//Fallback "VertexLit"
} 