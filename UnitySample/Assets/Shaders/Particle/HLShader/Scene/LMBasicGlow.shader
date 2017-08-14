// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "HL/Scene/LMBasicGlow" {
Properties {
	_Color ("Main Color", Color) = (.5, .5, .5, 1)
    _Splat0 ("Layer1 (RGB)", 2D) = "white" {}
    _Glow ("Glow (RGBA)", 2D) = "black" {}
}

CGINCLUDE
		#include "UnityCG.cginc"
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma target 2.0

		fixed4 _Color;
		sampler2D _Splat0 ;
		sampler2D _Glow;

		struct v2f {
			float4  pos : SV_POSITION;
			float2  uv[3] : TEXCOORD0;
		};

		float4 _Splat0_ST;
		float4 _Glow_ST;
        fixed4 unity_LightmapST;
        // sampler2D unity_Lightmap;

		v2f vert (appdata_full v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos (v.vertex);
			o.uv[0] = TRANSFORM_TEX (v.texcoord, _Splat0);
            o.uv[1] = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
			o.uv[2] = TRANSFORM_TEX (v.texcoord, _Glow);
			return o;
		}

		fixed4 frag (v2f i) : COLOR
		{
			fixed3 lay1 = tex2D(_Splat0, i.uv[0]).rgb;
			fixed4 glow = tex2D(_Glow,   i.uv[2]);
			fixed4 c = _Color;
			c.rgb *= lay1;
           	c.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv[1]));
			c.rgb += glow.rgb * glow.a;
			return c;
		}

		fixed4 frag_noLM (v2f i) : COLOR
		{
			fixed3 lay1 = tex2D(_Splat0, i.uv[0]).rgb;
			fixed4 glow = tex2D(_Glow,   i.uv[2]);
			fixed4 c = fixed4(_Color.rgb * 2, 1);
			c.rgb *= lay1;
           	//c.rgb *= DecodeLightmap(tex2D(unity_Lightmap, i.uv[1]));
			c.rgb += glow.rgb * glow.a;
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
		#pragma fragment frag_noLM
		ENDCG
    }
}

//Fallback "VertexLit"
} 