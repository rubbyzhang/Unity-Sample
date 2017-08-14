// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#warning Upgrade NOTE: unity_Scale shader variable was removed; replaced 'unity_Scale.w' with '1.0'

Shader "FX/SimpleWater" { 
Properties {
	_WaveScale ("Wave scale", Range (0.02,0.15)) = 0.063
	_BumpMap ("Normalmap ", 2D) = "bump" {}
	depthmap("depthmap", 2D) = "white" {}	
	WaveSpeed ("Wave speed (map1 x,y; map2 x,y)", Vector) = (19,9,-16,-7)
	_ReflectiveColor ("Reflective color (RGB) fresnel (A) ", 2D) = "" {}
	_HorizonColor ("Simple water horizon color", COLOR)  = ( .172, .463, .435, 1)
	_MainTex ("Fallback texture", 2D) = "" {}
}


// -----------------------------------------------------------
// Fragment program cards


Subshader { 
	Tags {"RenderType"="Opaque" "Queue"="Transparent-100"}
	Pass {
	Blend SrcAlpha OneMinusSrcAlpha
	ZTest LEqual
	ZWrite On
	Cull Off
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest 


#include "UnityCG.cginc"

uniform float4 _WaveScale4;
uniform float4 _WaveOffset;



struct appdata {
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float2 UV : TEXCOORD0;
};

struct v2f {
	float4 pos : SV_POSITION;
	float2 bumpuv0 : TEXCOORD0;
	float2 bumpuv1 : TEXCOORD1;
	float3 viewDir : TEXCOORD2;
	float2 depthuv : TEXCOORD3;

};

v2f vert(appdata v)
{
	v2f o;
	o.pos = UnityObjectToClipPos (v.vertex);
	
	// scroll bump waves
	float4 temp;
	temp.xyzw = v.vertex.xzxz * _WaveScale4 / 1.0 + _WaveOffset;
	o.bumpuv0 = temp.xy;
	o.bumpuv1 = temp.wz;
	
	o.depthuv = v.UV;
	
	// object space view direction (will normalize per pixel)
	o.viewDir.xzy = ObjSpaceViewDir(v.vertex);
	
	return o;
}


uniform sampler2D _ReflectiveColor;
uniform float4 _HorizonColor;
uniform sampler2D _BumpMap;
uniform sampler2D depthmap;

half4 frag( v2f i ) : SV_Target
{
	i.viewDir = normalize(i.viewDir);
	
	// combine two scrolling bumpmaps into one
	half3 bump1 = UnpackNormal(tex2D( _BumpMap, i.bumpuv0 )).rgb;
	half3 bump2 = UnpackNormal(tex2D( _BumpMap, i.bumpuv1 )).rgb;
	half3 bump = (bump1 + bump2) * 0.5;
	// fresnel factor
	half fresnelFac = dot( i.viewDir, bump );
	
	// perturb reflection/refraction UVs by bumpmap, and lookup colors

	// final color is between refracted and reflected based on fresnel	
	half4 color;
	
	half4 water = tex2D( _ReflectiveColor, float2(fresnelFac,fresnelFac) );
	color.rgb = lerp( water.rgb, _HorizonColor.rgb, water.a );
	
	half4 depthColor = tex2D( depthmap, i.depthuv );
	color.a = depthColor.r * (1 - water.a) + water.a;
	
	return color;
}
ENDCG

	}
}

// -----------------------------------------------------------
//  Old cards
// single texture
Subshader {
	Tags { "WaterMode"="Simple" "RenderType"="Opaque" }
	Pass {
		Color (0.5,0.5,0.5,0)
		SetTexture [_MainTex] {
			Matrix [_WaveMatrix]
			combine texture, primary
		}
	}
}


}
