// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

inline float3 BlendHardLight(float3 a, float3 b) 
{
    float3 r = float3(0,0,0);
    if (b.r > 0.5) { r.r = 1-(1-a.r)*(1-2*(b.r)); }
    else { r.r = a.r*(2*b.r); }
    if (b.g > 0.5) { r.g = 1-(1-a.g)*(1-2*(b.g)); }
    else { r.g = a.g*(2*b.g); }
    if (b.b > 0.5) { r.b = 1-(1-a.b)*(1-2*(b.b)); }
    else { r.b = a.b*(2*b.b); }
    return r;
}

inline float3 BlendLinearLight (float3 a, float3 b) 
{
    float3 r = float3(0,0,0);
    if (b.r > 0.5) { r.r = a.r+2*(b.r-0.5); }
    else { r.r = a.r+2*b.r-1; }
    if (b.g > 0.5) { r.g = a.g+2*(b.g-0.5); }
    else { r.g = a.g+2*b.g-1; }
    if (b.b > 0.5) { r.b = a.b+2*(b.b-0.5); }
    else { r.b = a.b+2*b.b-1; }
    return r;
}
inline float3 BlendPinLight(float3 a, float3 b) 
{
    float3 r = float3(0,0,0);
    if (b.r > 0.5) { r.r = max(a.r, 2*(b.r-0.5)); }
    else { r.r = min(a.r, 2*b.r); }
    if (b.g > 0.5) { r.g = max(a.g, 2*(b.g-0.5)); }
    else { r.g = min(a.g, 2*b.g); }
    if (b.b > 0.5) { r.b = max(a.b, 2*(b.b-0.5)); }
    else { r.b = min(a.b, 2*b.b); }
    return r;
}

struct v2f 
{
    float4 pos : SV_POSITION;
    float4 pack0 : TEXCOORD0; // _MainTex _LightTex
    half3 worldNormal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
    SHADOW_COORDS(3)
    UNITY_FOG_COORDS(4)

#if REALTIMEREFLECTION_ON
    float4 screenPos : TEXCOORD5;
#endif

#if NORMALMAP_ON
    float3 tSpace0 : TEXCOORD6;
    float3 tSpace1 : TEXCOORD7;
    float3 tSpace2 : TEXCOORD8;
#endif

    // fixed3 vlight : TEXCOORD6; // ambient/SH/vertexlights
};

float4 _MainTex_ST;
float4 _LightTex1_ST;

v2f vert(appdata_full v) 
{
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f, o);

    o.pos = UnityObjectToClipPos (v.vertex);
    o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.pack0.zw = TRANSFORM_TEX(v.texcoord1, _LightTex1);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    
#if REALTIMEREFLECTION_ON
    o.screenPos = ComputeScreenPos(o.pos);
#endif

#if NORMALMAP_ON
    float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
    float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
    float3 worldBinormal = cross(o.worldNormal, worldTangent) * tangentSign;
    o.tSpace0 = float4(worldTangent.x, worldBinormal.x, o.worldNormal.x, o.worldPos.x);
    o.tSpace1 = float4(worldTangent.y, worldBinormal.y, o.worldNormal.y, o.worldPos.y);
    o.tSpace2 = float4(worldTangent.z, worldBinormal.z, o.worldNormal.z, o.worldPos.z);
#endif

/*
#if UNITY_SHOULD_SAMPLE_SH
    float3 shlight = ShadeSH9 (float4(worldNormal,1.0));
    o.vlight = shlight;
#else
    o.vlight = 0.0;
#endif

#ifdef VERTEXLIGHT_ON
    o.vlight += Shade4PointLights (
      unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
      unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
      unity_4LightAtten0, worldPos, worldNormal );
#endif // VERTEXLIGHT_ON
*/

    TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
    UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
    return o;
}

sampler2D _MainTex;
sampler2D _LightTex1;
sampler2D _LightTex2;

fixed4 _BaseColor;
fixed4 _LightmapTone1;
fixed4 _LightmapTone2;
fixed4 _ShadowTone;

#if REALTIMEREFLECTION_ON
  sampler2D _ReflectionTex;
  fixed _ReflectionBlurSpread;
  fixed _ReflectionPower;
#endif

#if FAKEMETAL_ON
  sampler2D _MetalTex;
  sampler2D _MetallicTex;
#endif

#if NORMALMAP_ON
  sampler2D _NormalTex;
#endif

fixed4 frag(v2f IN) : SV_Target 
{
    fixed4 c = 0;
    
    fixed4 albedo = tex2D(_MainTex, IN.pack0.xy) * _BaseColor;
    fixed4 lmdata = tex2D(_LightTex1, IN.pack0.zw) * _LightmapTone1;

#if LIGHTMAP_BLENDMODE_MULTIPLY
    c.rgb = albedo.rgb * lmdata.rgb;
#else
  #if LIGHTMAP_BLENDMODE_HARDLIGHT
    c.rgb = BlendHardLight(albedo.rgb, lmdata.rgb);
  #endif
  
  #if LIGHTMAP_BLENDMODE_LINEARLIGHT
    c.rgb = BlendLinearLight(albedo.rgb, lmdata.rgb);
  #endif
  
  #if LIGHTMAP_BLENDMODE_PINLIGHT
    c.rgb = BlendPinLight(albedo.rgb, lmdata.rgb);
  #endif
#endif

    c.rgb  = lerp(albedo.rgb, c.rgb, _LightmapTone1.a);
    c.a    = albedo.a;

    // blend secondary lightmap with linear dodge
    lmdata = tex2D(_LightTex2, IN.pack0.zw) * _LightmapTone2;
    c.rgb  = lerp(c.rgb, min(c.rgb + lmdata.rgb, 1), _LightmapTone2.a);
    
#if REALTIMEREFLECTION_ON
    fixed2 reflection_uv = fixed2(IN.screenPos.xy) / IN.screenPos.w;
    fixed3 reflection = tex2D(_ReflectionTex, reflection_uv).rgb;
    c.rgb += reflection.rgb * _ReflectionPower;
#endif

#if NORMALMAP_ON
    float3 worldN = UnpackNormal(tex2D(_NormalTex, IN.pack0.xy));
    IN.worldNormal.x = dot(IN.tSpace0.xyz, worldN);
    IN.worldNormal.y = dot(IN.tSpace1.xyz, worldN);
    IN.worldNormal.z = dot(IN.tSpace2.xyz, worldN);
#endif

#if FAKEMETAL_ON
    fixed4 metal = tex2D(_MetalTex, IN.pack0.xy);
    fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(IN.worldPos));
    c.rgb += tex2D(_MetallicTex, saturate(dot(worldViewDir, IN.worldNormal))) * metal.r;
#endif

    // compute lighting & shadowing factor
    UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)

    c.rgb = lerp(c.rgb, _ShadowTone, (1-atten) * _ShadowTone.a);

    UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
    return c;
}
