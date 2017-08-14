// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "HL/Scene/LMDeepFog" {
Properties {
	_Color ("Main Color", Color) = (.5, .5, .5, 1)
	_MainTex ("Main Tex (RGB)", 2D) = "white" {}
	_Fog ("Fog Color", Color) = (1, 1, 1, 1)
	_FogTop ("FogTop", Float) = 0
	_FogBottom ("FogBottom", Float) = -10
}

CGINCLUDE
		#include "UnityCG.cginc"
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma target 2.0
		
		sampler2D _MainTex;
		fixed4 _Color;
		fixed4 _Fog;
		float _FogTop;
		float _FogBottom;

		struct v2f {
			float4  pos : SV_POSITION;
			float2  uv[3] : TEXCOORD0;
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
			o.uv[2].x = mul(unity_ObjectToWorld, v.vertex).y;
			return o;
		}

		fixed4 frag (v2f i) : COLOR
		{
			fixed3 lay1 = tex2D(_MainTex, i.uv[0]).rgb;
			fixed4 c = fixed4(_Color.rgb * 2.0, 1.0);
			c.rgb *= lay1;
           	c.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv[1]));

			//deep fog
			float factor = (_FogTop - i.uv[2].x) / (_FogTop - _FogBottom);
			factor = clamp(factor, 0, 1);
			c.rgb = lerp(c.rgb, _Fog.rgb, factor);

			return c;
		}

		fixed4 frag_noLM (v2f i) : COLOR
		{
			fixed3 lay1 = tex2D(_MainTex, i.uv[0]).rgb;
			fixed4 c = fixed4(_Color.rgb * 2.0, 1.0);
			c.rgb *= lay1;
           	//c.rgb *= DecodeLightmap(tex2D(unity_Lightmap, i.uv[1]));

			//deep fog
			float factor = (_FogTop - i.uv[2].x) / (_FogTop - _FogBottom);
			factor = saturate(factor);
			c.rgb = lerp(c.rgb, _Fog.rgb, factor);

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