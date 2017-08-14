#ifndef SHADING_COMMON_INCLUDED
#define SHADING_COMMON_INCLUDED

#include "UnityShaderVariables.cginc"
#include "UnityCG.cginc"

float4 EncodeFloatToRGBA8(float v)
{
	float topValue = ((255.0f*256.0f + 255.0f)*256.0f + 255.0f)*256.0f + 255.0f;
	v *= topValue;

	float d = fmod(v, 256.0f);
	v -= d;
	v /= 256.0f;

	float c = fmod(v, 256.0f);
	v -= c;
	v /= 256.0f;

	float b = fmod(v, 256.0f);
	v -= b;
	v /= 256.0f;

	float a = v;

	return float4(b, c, d, a) / 255.0f;
}

float DecodeRgba8ToFloat(float4 v)
{
	#define FLOAT_MULTIPLIER (1.0f / (1.0f + 256.0f + 256.0f * 256.0f + 256.0f * 256.0f * 256.0f))
	float4 srcFactor = float4(256.0f * 256.0f * FLOAT_MULTIPLIER, 256.0f* FLOAT_MULTIPLIER, 1.0f* FLOAT_MULTIPLIER, 256.0f * 256.0f * 256.0f* FLOAT_MULTIPLIER);

	return dot(v, srcFactor);
}

#define GLOSS_ENCODE_FACTOR 13.0f

inline float GetSpecPowerFromGloss(float gloss)
{
	return pow(2, GLOSS_ENCODE_FACTOR*gloss);
}

float KajiyaKaySpec(float3 t, float3 h, float specPower)
{
	float tdh = dot(t, h);
	return pow(sqrt(max(1.0f - tdh*tdh, 0.01f)), specPower);
}

void KajiyaKayPhyDirLighting(
	//output
	out float3 finalLighting, out float3 diffuseLighting, out float3 specLighting, out float3 adjustedDiffuse, out float ndl, out float ndh,
	//input lighting property
	float3 lightDir, float3 lightColor,
	//input
	float3 normal, float3 tangent, float3 viewDir, float3 diffuseColor, float specPower, float3 specColor, float fresnelFactor, float shadow,
	float3 tangentSec, float specPowerSec, float3 specColorSec)
{
	//const preparation
	float3 h = normalize(lightDir + viewDir);
	ndh = saturate(dot(normal, h));
	ndl = saturate(dot(lightDir, normal));
	float ndv = saturate(dot(viewDir, normal));
	float vdh = saturate(dot(viewDir, h));

	float3 spec = 0.0f;	
	float tdh = dot(tangent, h);
	spec = KajiyaKaySpec(tangent, h, specPower)*specColor*ndl;
	spec += KajiyaKaySpec(tangentSec, h, specPowerSec)*specColorSec*ndl;

	//diffuse calc
	adjustedDiffuse = diffuseColor;
	float3 dif = max(0.0f, 0.75f*ndl + 0.25f)*adjustedDiffuse;

	//light calc
	float3 lighting = shadow*lightColor;

	//final
	finalLighting = (dif + spec)*lighting;

	//this code will be optimized if not used
	diffuseLighting = dif*lighting;
	specLighting = spec*lighting;
}

//color shifting
#define INVALID_COLOR 666.0f
float4 ColorShiftHSL;
float4 ColorShiftRange;

float3 HslToRgb(float3 c)
{
	float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float3 RgbToHsl(float3 c)
{
	float4 K = float4(0.0f, -1.0f / 3.0f, 2.0f / 3.0f, -1.0f);
	float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
	float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void CustomColor(inout float3 color, float mask)
{
	float3 ohsl = RgbToHsl(color);
	bool valid = mask >= ColorShiftRange.x && mask <= ColorShiftRange.y;
	ohsl.r = (valid==false || ColorShiftHSL.r == INVALID_COLOR) ? ohsl.r : ColorShiftHSL.r*0.02f;
	ohsl.g = valid ? saturate(ohsl.g + ColorShiftHSL.g*0.02f) : ohsl.g;
	ohsl.b = valid ? saturate(ohsl.b + ColorShiftHSL.b*0.02f) : ohsl.b;
	color = HslToRgb(ohsl);
}

float ToneMapUvStandardize(float v)
{
	return clamp(v, 1.5f / 256.0f, 1 - 1.5f / 256.0f);
}

//env lighting variable
#if defined(UNITY_DIRECTIONALLIGHT)
#define CHARACTER_SUNLIGHTDIR _WorldSpaceLightPos0
#else
float4 CharacterSunLightDir;
#define CHARACTER_SUNLIGHTDIR CharacterSunLightDir
#endif
fixed4 CharacterSunLightColor;
fixed4 CharacterAmbientLightColor;

float4 HairAmbientLightColor;
float4 HairSunLightColor;
float4 HairGroundLightColor;

//player shadow part
UNITY_DECLARE_SHADOWMAP(PlayerShadowDepth);
float4x4 PlayerShadowDepthMvp;
float4 ShadowResolution;//the blur steps included
 
float SampleShadowPcf5(float3 worldPos)
{
	float4 homoPosShadowSpace = mul(PlayerShadowDepthMvp, float4(worldPos, 1.0f));
	float4 uvz = homoPosShadowSpace.xyzw / homoPosShadowSpace.w;
	uvz.xyz = (uvz.xyz + 1.0f)*0.5f;
	uvz.z *= 0.98f;

	float2 uv[5];
	uv[0] = uvz.xy;
	uv[1] = uv[0] + float2(ShadowResolution.x, 0.0f);
	uv[2] = uv[0] + float2(-ShadowResolution.x, 0.0f);
	uv[3] = uv[0] + float2(0.0f, ShadowResolution.x);
	uv[4] = uv[0] + float2(0.0f, -ShadowResolution.x);

	float kernel[5] = { 0.5f, 0.5f / 4, 0.5f / 4, 0.5f / 4, 0.5f / 4 };

	float shadow = 0;
	for (int i = 0; i < 5; i++)
	{
		shadow += UNITY_SAMPLE_SHADOW(PlayerShadowDepth, float4(uv[i].xy,uvz.zw)).x*kernel[i];
	}
	return shadow;
}

#endif	// SHADING_COMMON_INCLUDED