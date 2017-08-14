// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Water Ripple/Render"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
	}

	CGINCLUDE

	#include "UnityCG.cginc"

	struct v2f
	{
		float4 pos : POSITION;
		float2 uv[5] : TEXCOORD0;
	};

	sampler2D _PrevTex;
	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	float _Damping;
	float4 _MousePos;

	v2f vert(appdata_img v)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(v.vertex);

		float3 size = float3(_MainTex_TexelSize.x, -_MainTex_TexelSize.x, 0);

		o.uv[0] = v.texcoord.xy;
		o.uv[1] = v.texcoord.xy + size.xz;
		o.uv[2] = v.texcoord.xy + size.yz;
		o.uv[3] = v.texcoord.xy + size.zx;
		o.uv[4] = v.texcoord.xy + size.zy;

		return o;
	}

	fixed4 frag(v2f i) : COLOR
	{
		fixed orig = tex2D(_MainTex, i.uv[0]).r;
		return orig + step(length(_MousePos.xy - i.uv[0]), _MainTex_TexelSize.x);
	}

	fixed4 fragPropogate(v2f i) : COLOR
	{
		float sample = tex2D(_MainTex, i.uv[1]).r;
		sample += tex2D(_MainTex, i.uv[2]).r;
		sample += tex2D(_MainTex, i.uv[3]).r;
		sample += tex2D(_MainTex, i.uv[4]).r;

		//sample /= 4.0;

		float4 newValue = (sample * 0.5 - tex2D(_PrevTex, i.uv[0]).r)  * _Damping;
		//newValue.a = 1;
		return newValue;
	}

	fixed4 fragHeightToNormal(v2f i) : COLOR
	{
		fixed s11 = tex2D(_MainTex, i.uv[0]).r;
		fixed s21 = tex2D(_MainTex, i.uv[1]).r;
		fixed s01 = tex2D(_MainTex, i.uv[2]).r;
		fixed s12 = tex2D(_MainTex, i.uv[3]).r;
		fixed s10 = tex2D(_MainTex, i.uv[4]).r;
		fixed2 size = fixed2(0.2, 0);
		fixed3 va = normalize(fixed3(size.x, size.y,s21 - s01 ));
		fixed3 vb = normalize(fixed3(size.y, size.x,s12 - s10 ));
		fixed4 bump = fixed4(normalize(cross(va, vb)), 1);
		return bump;
	}

	ENDCG

Subshader {
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
	}

	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment fragPropogate
		ENDCG
	}

	Pass{
		ZTest Always Cull Off ZWrite Off
		Fog{ Mode off }

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment fragHeightToNormal
		ENDCG
	}
}

Fallback off

} // shader