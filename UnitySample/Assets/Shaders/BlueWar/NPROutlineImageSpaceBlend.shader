// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BlueWar/NPROutlineImageSpace"
{
	Properties{
		_MainTex("Base (RGB)", 2D) = "" {}
	}

		CGINCLUDE

#include "../ShadingCommon.cginc"

		struct v2f {
		float4 pos : POSITION;
		float2 uv[5] : TEXCOORD0;
	};

	float4 ResolutionInfo;
	float  OutlineDistanceInv;
	float4 OutlineColor;
	sampler2D _MainTex;

	v2f vert(appdata_img v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		float2 uv = v.texcoord.xy;
		o.uv[0] = v.texcoord.xy;
		o.uv[1] = uv + float2(ResolutionInfo.x, 0.0f);
		o.uv[2] = uv + float2(-ResolutionInfo.x, 0.0f);
		o.uv[3] = uv + float2(0.0f, ResolutionInfo.y);
		o.uv[4] = uv + float2(0.0f, -ResolutionInfo.y);
		return o;
	}

	half4 frag(v2f i) : COLOR{
		float4 color0 = tex2D(_MainTex, i.uv[1]);
		float4 color1 = tex2D(_MainTex, i.uv[2]);
		float4 color2 = tex2D(_MainTex, i.uv[3]);
		float4 color3 = tex2D(_MainTex, i.uv[4]);
		float4 color = tex2D(_MainTex, i.uv[0]);

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
