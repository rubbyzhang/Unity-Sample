// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "Terrain/Custom/Diffuse" {
Properties {
				_Splat0 ("Layer 1", 2D) = "black" {}
                _Splat1 ("Layer 2", 2D) = "black" {}
                _Splat2 ("Layer 3", 2D) = "black" {}
                _Splat3 ("Layer 4", 2D) = "black" {}
                _Control ("Control (RGBA)", 2D) = "black" {}
				_MainTex ("Never Used", 2D) = "black" {}
}
               
SubShader {
	Tags {
				   "SplatCount" = "4"
				   "Queue" = "Geometry-100"
				   "RenderType" = "Opaque"
	}

	// ------------------------------------------------------------
	// Surface shader code generated out of a CGPROGRAM block:
	

	// ---- forward rendering base pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

// Original surface shader snippet:
#line 20 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

//#pragma surface surf Lambert
//#pragma target 3.0

struct Input {
        float2 uv_Control : TEXCOORD0;
        float2 uv_Splat0 : TEXCOORD1;
        float2 uv_Splat1 : TEXCOORD2;
        float2 uv_Splat2 : TEXCOORD3;
        float2 uv_Splat3 : TEXCOORD4;
};
 
sampler2D _Control; //,_Control2;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;  //,_Splat4,_Splat5,_Splat6,_Splat7;
 
void surf (Input IN, inout SurfaceOutput o) 
{
        float4 splat_control = tex2D (_Control, IN.uv_Control).rgba;
        float3 col = float3(0,0,0);
        col  = splat_control.r * tex2D (_Splat0, IN.uv_Splat0).rgb;
        col += splat_control.g * tex2D (_Splat1, IN.uv_Splat1).rgb;
        col += splat_control.b * tex2D (_Splat2, IN.uv_Splat2).rgb;
		col += splat_control.a * tex2D (_Splat3, IN.uv_Splat3).rgb;

        o.Albedo = col.rgb;
        o.Alpha = 0.0;
}


// vertex-to-fragment interpolation data

#ifndef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0;
  float4 pack1 : TEXCOORD1;
  float2 pack2 : TEXCOORD2;
  float2 lmap : TEXCOORD3;
};
#endif
#ifndef LIGHTMAP_OFF
// float4 unity_LightmapST;
#endif
float4 _Control_ST;
float4 _Splat0_ST;
float4 _Splat1_ST;
float4 _Splat2_ST;
float4 _Splat3_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  o.pos = UnityObjectToClipPos (v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
  o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
  o.pack2.xy = TRANSFORM_TEX(v.texcoord, _Splat3);
  o.lmap.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;

  // pass lighting information to pixel shader
  TRANSFER_VERTEX_TO_FRAGMENT(o);
  return o;
}
#ifndef LIGHTMAP_OFF
// sampler2D unity_Lightmap;
#endif

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  // prepare and unpack data
  Input surfIN;
  surfIN.uv_Control = IN.pack0.xy;
  surfIN.uv_Splat0 = IN.pack0.zw;
  surfIN.uv_Splat1 = IN.pack1.xy;
  surfIN.uv_Splat2 = IN.pack1.zw;
  surfIN.uv_Splat3 = IN.pack2.xy;
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutput o = (SurfaceOutput)0;
  #else
  SurfaceOutput o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  o.Gloss = 0.0;

  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  fixed atten = LIGHT_ATTENUATION(IN);
  fixed4 c = 0;

  // lightmaps:
  #ifndef LIGHTMAP_OFF
  // single lightmap
  fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy);
  fixed3 lm = DecodeLightmap (lmtex);
   
  c.rgb = o.Albedo * lm;
  c.a = o.Alpha;
  #else
  c.rgb = o.Albedo;
  c.a = o.Alpha;
  #endif

  return c;
}

ENDCG



}
}
FallBack "Diffuse"
}
