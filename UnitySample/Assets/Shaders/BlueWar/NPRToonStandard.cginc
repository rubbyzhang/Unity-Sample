#ifndef NPRTOONSTANDARD_INCLUDED
#define NPRTOONSTANDARD_INCLUDED

#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "NPRToonLighting.cginc"

#define NPRTOON_VS_COMMON(type, o) \
    type o;                                                                                    \
    UNITY_INITIALIZE_OUTPUT(type, o);                                                          \
    o.pos = UnityObjectToClipPos(v.vertex);                                                    \
    o.uv.xy = v.texcoord;                                                                      \
    half3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;                                   \
    fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);                                   \
    o.worldNormal.xyz = normalize(worldNormal);                                                \
    o.worldCamDir.xyz = normalize(UnityWorldSpaceViewDir(worldPos));                           \
    o.worldPos.xyz = worldPos;                                                                 \
    o.worldNormal.w = v.color.r;                                                               \
    o.worldCamDir.w = v.color.g;                                                               \
    o.worldPos.w = v.color.b;                                                                  \
    TRANSFER_SHADOW(o);                                                                        \
    o.vlight.a = v.color.a;                                                                    \
    o.vlight.rgb = ToonVertexPointLight(o.worldNormal.xyz, o.worldPos,o.worldCamDir.xyz);
          

#define NPRTOON_PS_COMMON \
    fixed4 lightColor = ToonLightColor();                                                      \
    fixed4 vc         = fixed4(IN.worldNormal.w, IN.worldCamDir.w, IN.worldPos.w, IN.vlight.a);\
    half2 shadow      = LIGHT_ATTENUATION(IN);                                                 \
    half4 shading     = tex2D(_ShadingMask, IN.uv.xy);                                         \
    shading.g         = shading.g * 0.5;                                                       \
    half4 diffuse     = tex2D(_MainTex, IN.uv.xy);                                             \
    half3 lightDir    = ToonLightDir().xyz;                                                    \
    half3 normal      = normalize(IN.worldNormal.xyz);                                         \
    half3 viewDir     = IN.worldCamDir.xyz;                                                    \
    diffuse.rgb       = CombineDecal(IN.uv.xy, diffuse.rgb);                                   \
    half4 rim         = 0;                                                                     \
    half4 specular    = 0;                                                                     \
    half3 color       = half3(IN.worldNormal.w, IN.worldCamDir.w, IN.worldPos.w);              \
    half3 lighting    = ToonBaseLighting(normal, lightDir, shading.rgb, lightColor.rgb, shadow);

struct v2f_standard 
{
    half4 pos : SV_POSITION;
    half4 uv: TEXCOORD0;
    half4 worldNormal: TEXCOORD1;
    half4 worldPos: TEXCOORD2;
    half4 worldCamDir: TEXCOORD3;
    half4 vlight: TEXCOORD4;
    LIGHTING_COORDS(5, 6)
};

struct v2f_anisotropy 
{
    half4 pos : SV_POSITION;
    half4 uv: TEXCOORD0;
    half4 worldNormal: TEXCOORD1;
    half4 worldPos: TEXCOORD2;
    half4 worldCamDir: TEXCOORD3;
    half4 vlight: TEXCOORD4;
    half4 tangent: TEXCOORD5;
    LIGHTING_COORDS(6, 7)
};

// global properties
half _Fade;
fixed4 _Color;

// common properties
sampler2D _MainTex;
sampler2D _ShadingMask;
half4 _ShadingMask_ST;
sampler2D _GlossyMatcap;

// decal related properties
sampler2D _DecalTex;
half4 DecalUV;

// rim lighting related properties
half RimGeneral;
half RimPower;

// specular related properties    
half SpecularPower;
half SpecularFactor;

inline half GetMipFromRoughness(half roughness)
{
    half level = 3 - 1.15 * log2(roughness);
    return 9.0 - 1 - level;
}

inline fixed3 CombineDecal(half2 uv, half3 diffuse)
{
#if USE_DECAL
    half2 uv01 = frac(uv.xy);
    half2 decalUV = (uv01 - DecalUV.xy) * DecalUV.zw + half2(0.5f, 0.5f);
    decalUV.xy = saturate(decalUV.xy);
    fixed4 diffuseDecal = tex2D(_DecalTex, decalUV);
    return lerp(diffuse.rgb, diffuseDecal.rgb, diffuseDecal.a);
#else
    return diffuse.rgb;
#endif
}

inline fixed4 CombineLighting(half4 albedo, half3 dLight, half3 pLight, half4 rim, half3 specular)
{
    half3 result = (lerp(albedo.xyz, rim.rgb, rim.a) + specular) * (ToonAmbientColor().rgb + dLight + pLight);

#if defined(USE_ALPHABLEND)
    return fixed4(result, _Fade * albedo.a);
#else
  #if defined(FADEPASS)
    return fixed4(result, _Fade);
  #else
    return fixed4(result, 1);
  #endif
#endif
}

// vertex shader
v2f_standard NPRToonCharacterStandardVS(appdata_full v) 
{
    NPRTOON_VS_COMMON(v2f_standard, o);
#if USE_GLOSSYREFLECTION
    o.uv.zw = half2(dot(UNITY_MATRIX_IT_MV[0].xyz,v.normal), dot(UNITY_MATRIX_IT_MV[1].xyz,v.normal));
    o.uv.zw = o.uv.zw * 0.5 + 0.5;
#endif
    return o;
}

// anisotropy vertex shader
v2f_anisotropy NPRToonCharacterAnisotropyVS(appdata_full v) 
{
    NPRTOON_VS_COMMON(v2f_anisotropy, o);
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _ShadingMask);
    o.tangent.xyz = normalize(UnityObjectToWorldNormal(v.tangent));
    return o;
}

// fragment shader for anisotropy object rendering
uniform half   _AnisotropyShift1; 
uniform half   _AnisotropyShift2; 
uniform half   _AnisotropyPower1; 
uniform half   _AnisotropyPower2;
uniform fixed4 _SpecularColor1;
uniform fixed4 _SpecularColor2;
fixed4 NPRToonCharacterAnisotropyPS(v2f_anisotropy IN) : SV_Target
{
    NPRTOON_PS_COMMON;

#if defined(INVERT_NORMAL)
    normal = -normal;
#endif

#if USE_RIMLIGHTING
    rim.rgb = ToonRimColor(shading.rgb);
    rim.a   = ToonRimLighting(normal, viewDir, RimGeneral, RimPower) * shadow.y * vc.a;
#endif

    // sample jitter&shift texture with tiled uv
    half4 anisotropyShading = tex2D(_ShadingMask, IN.uv.zw);
    half2 anisotropy = ToonAnisotropyLighting(IN.tangent, normal, viewDir, lightDir, anisotropyShading, 
        half2(_AnisotropyShift1, _AnisotropyShift2), half2(_AnisotropyPower1, _AnisotropyPower2), max(0.25, shadow.y));

    anisotropy *= half2(_SpecularColor1.a, _SpecularColor2.a) * lightColor.a * vc.a;

    half aniso = anisotropy.x + anisotropy.y;

    // special combine formula for anisotropy specular lighting
    specular.rgb = (anisotropy.x * _SpecularColor1 + anisotropy.y * _SpecularColor2);
    fixed4 final = CombineLighting(diffuse, lighting, IN.vlight.rgb, rim, specular.rgb);

    return fixed4(lerp(final.rgb, specular.rgb, saturate(aniso)), final.a);
}

// fragment shader for general character rendering 
fixed4 NPRToonCharacterStandardPS(v2f_standard IN): SV_Target 
{
    NPRTOON_PS_COMMON;

#if USE_RIMLIGHTING
    rim.rgb = ToonRimColor(shading.rgb);
    rim.a   = ToonRimLighting(normal, viewDir, RimGeneral, RimPower) * color.r;
#endif

#if USE_SPECULARLIGHTING
    specular.rgb = ToonSpecularColor(shading.rgb);
    specular = ToonSpecularLighting(normal, viewDir, lightDir, SpecularPower, SpecularFactor, shading.rgb, specular);
#endif

    fixed4 result = CombineLighting(diffuse, lighting, IN.vlight.rgb, rim, specular);

#if USE_GLOSSYREFLECTION
    fixed3 glossyRefl = tex2D(_GlossyMatcap, IN.uv.zw).rgb;
    result.rgb = lerp(result.rgb, glossyRefl * 2.0 * lightColor.a, shading.a);
#endif
    
    return result;
}

#endif