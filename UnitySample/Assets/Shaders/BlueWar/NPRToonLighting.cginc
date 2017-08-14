#ifndef NPRTOONLIGHTING_INCLUDED
#define NPRTOONLIGHTING_INCLUDED

#include "../ShadingCommon.cginc"

uniform sampler2D _ToonMap;
uniform half      _LightSmoothness;
uniform half      _LightThreshold;

uniform fixed4    _ToonLightColor;
uniform fixed4    _ToonAmbientColor;
uniform half3     _ToonLightDir;

#define TOON_NDL(ndl) ( smoothstep( _LightThreshold - _LightSmoothness * 0.5, _LightThreshold + _LightSmoothness * 0.5, (ndl) ) )

inline fixed4 ToonLightColor()
{
#if USE_LOCALLIGHT
    return _ToonLightColor;	
#else
    return CharacterSunLightColor;
#endif
}

inline fixed4 ToonAmbientColor()
{
#if USE_LOCALLIGHT
    return _ToonAmbientColor;	
#else
    return CharacterAmbientLightColor;
#endif
}

inline half3 ToonLightDir()
{
#if USE_LOCALLIGHT
    return _ToonLightDir;	
#else
    return CHARACTER_SUNLIGHTDIR;
#endif
}

float3 ToonShade4PointLights(
    float4 lightPosX, float4 lightPosY, float4 lightPosZ,
    float3 lightColor0, float3 lightColor1, float3 lightColor2, float3 lightColor3,
    float4 lightAttenSq,
    float3 pos, float3 normal, float3 view)
{
    // to light vectors
    float4 toLightX = lightPosX - pos.x;
    float4 toLightY = lightPosY - pos.y;
    float4 toLightZ = lightPosZ - pos.z;
    // squared lengths
    float4 lengthSq = 0;
    lengthSq += toLightX * toLightX;
    lengthSq += toLightY * toLightY;
    lengthSq += toLightZ * toLightZ;
    // NdotL
    float4 ndotl = 0;
    ndotl += toLightX * normal.x;
    ndotl += toLightY * normal.y;
    ndotl += toLightZ * normal.z;
    // correct NdotL
    float4 corr = rsqrt(lengthSq);
    ndotl = max (float4(0,0,0,0), ndotl * corr);
    // attenuation
    float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
    float4 diff = saturate(dot(normal, view) * 0.5 + 0.5) * atten;
    // final color
    float3 col = 0;
    col += smoothstep(0.0, 1.5, lightColor0 * diff.x);
    col += smoothstep(0.0, 1.5, lightColor1 * diff.y);
    col += smoothstep(0.0, 1.5, lightColor2 * diff.z);
    col += smoothstep(0.0, 1.5, lightColor3 * diff.w);
    return col * 0.7;
}

inline half3 ToonVertexPointLight(half3 wsNormal, half3 wsPos, half3 wsView)
{
    half3 result = 0;
    
    // Approximated illumination from non-important point lights
#ifdef VERTEXLIGHT_ON
    result = ToonShade4PointLights(
          unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
          unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
          unity_4LightAtten0, wsPos, wsNormal, wsView);
#endif

    return result;
}

inline half3 ToonRimColor(half3 shading)
{
    return tex2D(_ToonMap, half2(0, shading.g)).rgb;
}

inline half3 ToonSpecularColor(half3 shading)
{
    return tex2D(_ToonMap, half2(1, shading.g)).rgb;
}

inline half3 ToonBaseLighting(half3 normal, half3 lightDir, half3 shading, half3 domainColor, inout half2 shadow)
{
    shadow.x = dot(normal, lightDir);

    half ndl = max(shadow.x + (shading.r * 2 - 1), 0);
    ndl = TOON_NDL(ndl);

    shadow.x = saturate(shadow.x);
    shadow.y = min(ndl, max(shading.r * 0.85, shadow.y));

    half4 result = tex2D(_ToonMap, half2(shadow.y, shading.g + 0.5f));

    return result.rgb * domainColor;
}

inline half ToonRimLighting(half3 normal, half3 view, half threshold, half power)
{
    half edh = max(dot(view, normal), 0);
    edh = smoothstep(threshold - 0.5 * 0.5, threshold + 0.5 * 0.5, edh);

    return pow(1 - edh, power);
}

inline half4 ToonSpecularLighting(half3 normal, half3 view, half3 lightDir, half power, half factor, half3 shading, half3 domainColor)
{
    half3 h = normalize(lightDir + view);
     half ndh = saturate(dot(normal, h));

    half spec = pow(ndh, power) * shading.b;
    return half4(tex2D(_ToonMap, half2(spec * factor, 0.55f)).rgb * domainColor, spec);
}

inline half StrandSpec(half3 tangent, half3 L, half3 V, half power)
{
    half3 H     = normalize(L + V);
    half  TdotH = dot(tangent, H);
    half  sinTH = sqrt(1 - TdotH * TdotH);
    return 0.25 * pow(sinTH, power) * smoothstep(-1, 0, dot(tangent, H));
}

inline half2 ToonAnisotropyLighting(half3 tangent, half3 normal, half3 view, half3 lightDir, half4 shading, half2 shift, half2 power, half shadow)
{
    half2 jitterShift = shading.ba;

#ifdef FULL_ANISOTROPYLIGHTING
    half jitter = jitterShift.x * 0.5;
    jitterShift.y = lerp(jitter - 0.5, jitter + 0.5, jitterShift.y);
#endif

    half2 anisotropy = 0;

    // Primary specular highlight
    half3 tanA = normalize(tangent + normal * (jitterShift.y + shift.x));
    anisotropy.x = 4.0 * StrandSpec(tanA, lightDir, view, power.x) * shadow;

#ifdef FULL_ANISOTROPYLIGHTING
    // Secondary specular highlight
    half3 tanB = normalize(tangent + normal * (jitterShift.y + shift.y));
    anisotropy.y = 4.0 * StrandSpec(tanB, lightDir, view, power.y) * shadow;
#endif

    return anisotropy; 
}

#endif