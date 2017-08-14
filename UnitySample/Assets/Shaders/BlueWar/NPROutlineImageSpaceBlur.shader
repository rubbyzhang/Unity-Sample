// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BlueWar/NPROutlineImageSpaceBlur"
{
	Properties{
		_MainTex("Base (RGB)", 2D) = "" {}
	}

		CGINCLUDE

#include "../ShadingCommon.cginc"

	struct v2f {
		float4 pos : POSITION;
		float2 uv : TEXCOORD0;
	};

	float4 ResolutionInfo;
	sampler2D _MainTex;

	v2f vert(appdata_img v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv.xy = v.texcoord.xy;
		return o;
	}

	half4 frag(v2f i) : COLOR{
		half2 baseUv = i.uv;

		float2 uv0 = float2(ResolutionInfo.x, 0.0f);
		float2 uv1 = float2(-ResolutionInfo.x, 0.0f);
		float2 uv2 = float2(0.0f, ResolutionInfo.y);
		float2 uv3 = float2(0.0f, -ResolutionInfo.y);

		float4 color0 = tex2D(_MainTex, baseUv + uv0);
		float4 color1 = tex2D(_MainTex, baseUv + uv1);
		float4 color2 = tex2D(_MainTex, baseUv + uv2);
		float4 color3 = tex2D(_MainTex, baseUv + uv3);
		float4 color = tex2D(_MainTex, baseUv);

		color += color0;
		color += color1;
		color += color2;
		color += color3;
		color *= 0.2f;
		color *= color;//darken

		return color;
	}

		ENDCG

		Subshader {
		Pass{
			ZTest Always Cull Off ZWrite Off
			Fog{ Mode off }
			Blend Zero SrcColor
			Stencil{
			Ref 128
			ReadMask 128
			Comp Equal
		}
			CGPROGRAM
#pragma fragmentoption ARB_precision_hint_fastest
#pragma vertex vert
#pragma fragment frag
			ENDCG
		}
	}

	Fallback off


} // shader
