// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "BlueWar/BlendSkyBox" {
Properties {
	_FogIntensity ("Fog Intensity", Range(0.01,1.00)) = 0.01
    _Height("Height", Range(-1, 1)) = 0
    _Rotation("Rotation", Range(-3.1415, 3.1415)) = 0

	[HideInInspector]_FlowBlend  ("blend between 01",Range(0.0,1.0)) = 0.0
	[HideInInspector]_TransBlend ("Blend between 012",Range(0.0,1.0))= 0.0

	//[HideInInspector][NoScaleOffset] _FrontTexSrc ("Front [+Z]   (HDR)", 2D) = "grey" {}
	[NoScaleOffset] _FrontTexSrc ("Front [+Z]   (HDR)", 2D) = "grey" {}
	[NoScaleOffset] _BackTexSrc("Back [-Z]   (HDR)", 2D) = "grey" {}
	[NoScaleOffset] _LeftTexSrc("Left [+X]   (HDR)", 2D) = "grey" {}
	[NoScaleOffset] _RightTexSrc("Right [-X]   (HDR)", 2D) = "grey" {}
	[NoScaleOffset] _UpTexSrc("Up [+Y]   (HDR)", 2D) = "grey" {}
	[NoScaleOffset] _DownTexSrc("Down [-Y]   (HDR)", 2D) = "grey" {}

	//[HideInInspector][NoScaleOffset] _FrontTexDst ("Front [+Z]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _FrontTexDst ("Front [+Z]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _BackTexDst("Back [-Z]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _LeftTexDst("Left [+X]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _RightTexDst("Right [-X]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _UpTexDst("Up [+Y]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _DownTexDst("Down [-Y]   (HDR)", 2D) = "grey" {}

	//[HideInInspector][NoScaleOffset] _FrontTexTrans ("Front [+Z]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _FrontTexTrans ("Front [+Z]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _BackTexTrans("Back [-Z]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _LeftTexTrans("Left [+X]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _RightTexTrans("Right [-X]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _UpTexTrans("Up [+Y]   (HDR)", 2D) = "grey" {}
	[HideInInspector][NoScaleOffset] _DownTexTrans("Down [-Y]   (HDR)", 2D) = "grey" {}
}
SubShader {
	Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
	Cull Off ZWrite Off Fog { Mode Off }
	
	CGINCLUDE
	#include "UnityCG.cginc"

	fixed _FogIntensity;
    fixed _Height;
    fixed _Rotation;
	fixed4 _BloomPower;

    half _FlowBlend;
	half _TransBlend;

	float4 RotateAroundYInDegrees (float4 vertex, float degrees)
	{
		float alpha = degrees * UNITY_PI / 180.0;
		float sina, cosa;
		sincos(alpha, sina, cosa);
		float2x2 m = float2x2(cosa, -sina, sina, cosa);
		return float4(mul(m, vertex.xz), vertex.yw).xzyw;
	}
	
	struct appdata_t {
		float4 vertex : POSITION;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f {
         float4 vertex : POSITION;
         float2 texcoord : TEXCOORD0;
         float4 dir: TEXCOORD1;
    };

	v2f vert (appdata_t v) {
         v2f o;

         v.vertex.y += _Height;

         float x = v.vertex.x;
         float z = v.vertex.z;
         
         float c, s;
         sincos(_Rotation, s, c);
         v.vertex.x = c * x - s * z;
         v.vertex.z = s * x + c * z;

         o.vertex = UnityObjectToClipPos(v.vertex);
         o.texcoord = v.texcoord;
         o.dir = mul(unity_ObjectToWorld, v.vertex);
         return o;
    }

	half4 skybox_frag (v2f i, sampler2D smpSrc,sampler2D smpDst,sampler2D smpTrans,half4 smpDecode)
	{
		half4 texSrc = tex2D(smpSrc, i.texcoord);
		half3 c = texSrc;

#if FLOWING || TRANSITING
		half4 texDst = tex2D(smpDst, i.texcoord);
		half3 c1 = texDst;
		c = lerp(c,c1,_FlowBlend);
#endif

#if TRANSITING
		half4 texTrans = tex2D(smpTrans, i.texcoord);
		half3 c2 = texTrans;
		c = lerp(c,c2,_TransBlend);
#endif

        half fog = 1 - saturate((normalize(i.dir).y) / _FogIntensity); // fog vanishes upwards
		c = lerp(c, unity_FogColor, fog * fog); // blend skybox with fog

		// return fixed4(c.rgb, 1);
		return fixed4(c.rgb * _BloomPower.x, 1);
	}
	ENDCG
	
	Pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile __ FLOWING
		#pragma multi_compile __ TRANSITING
		sampler2D _FrontTexSrc;
		sampler2D _FrontTexDst;
		sampler2D _FrontTexTrans;
		half4 _FrontTex_HDR;
		half4 frag (v2f i) : SV_Target { return skybox_frag(i,_FrontTexSrc,_FrontTexDst,_FrontTexTrans, _FrontTex_HDR); }
		ENDCG 
	}
	Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile __ FLOWING
		#pragma multi_compile __ TRANSITING		
		sampler2D _BackTexSrc;
		sampler2D _BackTexDst;
		sampler2D _BackTexTrans;
		half4 _BackTex_HDR;
		half4 frag (v2f i) : SV_Target { return skybox_frag(i,_BackTexSrc,_BackTexDst,_BackTexTrans, _BackTex_HDR); }
		ENDCG 
	}
	Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile __ FLOWING
		#pragma multi_compile __ TRANSITING	
		sampler2D _LeftTexSrc;
		sampler2D _LeftTexDst;
		sampler2D _LeftTexTrans;
		half4 _LeftTex_HDR;
		half4 frag (v2f i) : SV_Target { return skybox_frag(i,_LeftTexSrc,_LeftTexDst,_LeftTexTrans, _LeftTex_HDR); }
		ENDCG
	}
	Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile __ FLOWING
		#pragma multi_compile __ TRANSITING		
		sampler2D _RightTexSrc;
		sampler2D _RightTexDst;
		sampler2D _RightTexTrans;
		half4 _RightTex_HDR;
		half4 frag (v2f i) : SV_Target { return skybox_frag(i,_RightTexSrc,_RightTexDst,_RightTexTrans, _RightTex_HDR); }
		ENDCG
	}	
	Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile __ FLOWING
		#pragma multi_compile __ TRANSITING		
		sampler2D _UpTexSrc;
		sampler2D _UpTexDst;
		sampler2D _UpTexTrans;
		half4 _UpTex_HDR;
		half4 frag (v2f i) : SV_Target { return skybox_frag(i,_UpTexSrc,_UpTexDst,_UpTexTrans, _UpTex_HDR); }
		ENDCG
	}	
	Pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile __ FLOWING
		#pragma multi_compile __ TRANSITING		
		sampler2D _DownTexSrc;
		sampler2D _DownTexDst;
		sampler2D _DownTexTrans;
		half4 _DownTex_HDR;
		half4 frag (v2f i) : SV_Target { return skybox_frag(i,_DownTexSrc,_DownTexDst,_DownTexTrans, _DownTex_HDR); }
		ENDCG
	}
}
}
