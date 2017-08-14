// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Toon/Lighted-AlphaTest" {
	Properties {
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_GlowTex ("Glow", 2D) = "black" {}
		
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {} 
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		_EdgeLightColor( "Edge Light Color", Color ) = (0, 0, 0)
	}
	

	SubShader {
		//Tags { "RenderType"="Opaque" }
		Tags { "Queue"="Transparent-10" "RenderType" = "Opaque" }
		LOD 200
		
		Cull Back
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha
		
CGPROGRAM

#pragma surface surf ToonRamp vertex:vert


sampler2D _Ramp;

// custom lighting function that uses a texture ramp based
// on angle between light direction and normal
#pragma lighting ToonRamp exclude_path:prepass
inline half4 LightingToonRamp (SurfaceOutput s, half3 lightDir, half atten)
{
	#ifndef USING_DIRECTIONAL_LIGHT
	lightDir = normalize(lightDir);
	#endif
	

	half d = dot (s.Normal, lightDir)*0.5 + 0.5;
	half3 ramp = tex2D (_Ramp, float2(d,d)).rgb;
	
	half4 c;
	c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
	c.a = s.Alpha;
	return c;
}


sampler2D _MainTex;
sampler2D _GlowTex;

float4 _Color;
float _Cutoff;
float4 _EdgeLightColor;

struct Input {
	float2 uv_MainTex : TEXCOORD0;
    float4 posWorld : TEXCOORD1;
    float3 normalDir : TEXCOORD2;
};

void vert (inout appdata_full v, out Input data) {
	data.uv_MainTex = v.texcoord;
	data.posWorld = mul(unity_ObjectToWorld, v.vertex);
	data.normalDir = mul(float4(v.normal,0), unity_WorldToObject).xyz;
}

void surf (Input IN, inout SurfaceOutput o) {
	half4 c = tex2D(_MainTex, IN.uv_MainTex);
	half4 glowColor = tex2D(_GlowTex, IN.uv_MainTex );
	
	float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - IN.posWorld.xyz);
	float3 emissive = saturate((_EdgeLightColor.rgb*pow(1.0-max(0,dot(IN.normalDir, viewDirection)),1.0)));

	o.Albedo = c.rgb * _Color.rgb + emissive + glowColor;
	o.Alpha = c.a;
	
	if ( o.Alpha - _Cutoff <= 0.0f )
		discard;
	o.Alpha *= _Color.a;

}
ENDCG

	} 

	Fallback "Diffuse"
}
