// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BlueWar/NPROutlineImageSpaceGen"
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
	float  OutlineDistanceInv;
	float4 OutlineColor;
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

		float depth0 = DecodeRgba8ToFloat(color0);
		float depth1 = DecodeRgba8ToFloat(color1);
		float depth2 = DecodeRgba8ToFloat(color2);
		float depth3 = DecodeRgba8ToFloat(color3);
		float depth = DecodeRgba8ToFloat(color);

		float depthDelta = max(depth0 - depth, 0);
		depthDelta = max(depthDelta, depth1 - depth);
		depthDelta = max(depthDelta, depth2 - depth);
		depthDelta = max(depthDelta, depth3 - depth);

		depthDelta = saturate(depthDelta*100.0f);
		depthDelta = depthDelta < 0.1f ? 0.0f : depthDelta;

		float minDepth0 = min(depth, depth0);
		float minDepth1 = min(depth1, depth2);
		float minDepth = min(min(minDepth0, minDepth1), depth3);
		float depthRatio = saturate(minDepth * 20 * OutlineDistanceInv);

		float4 finalColor = lerp(1.0f, OutlineColor, depthDelta);
		finalColor = lerp(finalColor, 1.0f, depthRatio);

		return finalColor;
	}

		ENDCG

		Subshader {
		Pass{
			ZTest Always Cull Off ZWrite Off
			Fog{ Mode off }
			Blend Off
			CGPROGRAM
#pragma fragmentoption ARB_precision_hint_fastest
#pragma vertex vert
#pragma fragment frag
			ENDCG
		}
	}

	Fallback off


} // shader
