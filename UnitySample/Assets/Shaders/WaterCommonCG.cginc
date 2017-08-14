// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#ifndef WATER_COMMON_CG_INCLUDED
#define WATER_COMMON_CG_INCLUDED

//float3 _Scale;
//float _Height;
//float _Distance;
//
//float4 ComputeSunWorldPosition(float4 vertex)
//{
//	// Suppose the center in object space is fixed
//	float3 light = normalize(float3(_WorldSpaceLightPos0.x, 0.0, _WorldSpaceLightPos0.z));
//	float3 center = _WorldSpaceCameraPos + light * _Distance + float3(0, _Height, 0);
//	float3 viewer = _WorldSpaceCameraPos;
//
//	// Way 1: Only fix position, not billboard
//	//float3 centerOffs = mul(_Object2World, vertex).xyz;
//	//newPos = mul(UNITY_MATRIX_VP, float4(centerOffs.xyz + center.xyz, 1.0));
//
//	// Way 2: Use billboard
//	float3 normalDir = viewer - center;
//	normalDir = normalize(normalDir);
//	float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
//	float3 rightDir = normalize(cross(upDir, normalDir));
//	upDir = normalize(cross(normalDir, rightDir));
//
//	// Use the three vectors to rotate the quad
//
//	float3 centerOffs = vertex * _Scale;
//	float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
//
//	return float4(localPos, 1);
//}
//
//float4 ComputeSunPosition(float4 vertex)
//{
//	float4 worldPos = ComputeSunWorldPosition(vertex);
//	float4 pos = mul(UNITY_MATRIX_VP, worldPos);
//	return pos;
//}

sampler2D _WavesTexture;
float _SmallWavesTiling;
float _LargeWavesTiling;
half _SmallWaveRefraction;
half _LargeWaveRefraction;

float _SpeedX;
float _SpeedZ;
float _WaveSpeed;

sampler2D _RampTex;

#ifdef _USESHORELINE_ON
half _ShoreLineIntensity;
sampler2D _ShoreLineTex;
float4 _ShoreLineTex_ST;
#endif
#ifdef _USEGROUNDTEX_ON
sampler2D _GroundTex;
half _GroundIntensity;
#endif

#ifdef _WATERMODE_MEDIUM
samplerCUBE _Cubemap;
#endif
#ifdef _WATERMODE_HIGH
sampler2D _ReflectionTex;
#endif

#ifdef _BLEND
samplerCUBE _Cubemap2;
float		_BlendRatio;
#endif
half _SunIntensity;
half _ReflDistort;
half _ReflAmount;

fixed4 _LightWaterColor;
fixed4 _DeepWaterColor;

fixed4 _Specular;
half _Gloss;

uniform half _ReflStart;
uniform half _ReflRange;
uniform fixed4 _ReflColor;

struct a2v_water {
	float4 vertex : POSITION;
	float4 texcoord : TEXCOORD0;
};
struct v2f_water {
	float4 pos : SV_POSITION;
	float4 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float4 worldPos : TEXCOORD2;
	float4 scrPos : TEXCOORD3;
#if defined (_FOGMODE_SCENE) || defined (_FOGMODE_CAMERA)
	float4 viewPos : TEXCOORD4;
#endif
};

v2f_water water_vert(a2v_water v) {
	v2f_water o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.scrPos = ComputeScreenPos(o.pos);
#if defined (_FOGMODE_SCENE) || defined (_FOGMODE_CAMERA)
	o.viewPos = mul(UNITY_MATRIX_MV, v.vertex);
#endif

	float4 uv;
	uv.xy = o.worldPos.xz;
	uv.zw = frac(_Time.x * _WaveSpeed);
	float2 speed = float2(_SpeedX, _SpeedZ) * _Time.x;

	o.uv0.xy = uv.xy * _SmallWavesTiling + uv.zw + speed;
	o.uv0.zw = uv.xy * _LargeWavesTiling - uv.zw + speed;
	o.uv1.xy = v.texcoord.xy;

	return o;
}

fixed4 water_frag(v2f_water i) : SV_Target{
	// Directions
	float3 worldPos = i.worldPos.xyz;
	half3 worldView = normalize(_WorldSpaceCameraPos.xyz - worldPos);
	half3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

	fixed4 col = _LightWaterColor;

	///
	/// Scale normal
	///
	half3 smallNorm = (tex2D(_WavesTexture, i.uv0.xy)).xyz * 2.0 - 1.0;
	half3 largeNorm = (tex2D(_WavesTexture, i.uv0.zw)).xyz * 2.0 - 1.0;

	///
	/// Compute normal
	///
	half3 worldNormal = lerp(half3(0, 1, 0), smallNorm, _SmallWaveRefraction) +
		lerp(half3(0, 1, 0), largeNorm, _LargeWaveRefraction);
	worldNormal = normalize(worldNormal);

	///
	/// Diffuse
	///
	half NdotL = dot(worldNormal, worldLight) * 0.5 + 0.5;
	half diff = tex2D(_RampTex, half2(NdotL, NdotL)).r;
	col.rgb = lerp(_DeepWaterColor.rgb, _LightWaterColor.rgb, diff);

	///
	/// Fresnel
	///
	half NdotV = saturate(dot(worldNormal, worldView));
	half fresnel = 1;
	//fresnel = 1.0 - NdotV;

	///
	/// Reflect sky
	///
#ifdef _WATERMODE_MEDIUM
	half3 reflNormal = normalize(lerp(half3(0, 1, 0), worldNormal, _ReflDistort));
	half3 reflDir = reflect(-worldView, reflNormal);
	fixed4 skybox = texCUBE(_Cubemap, reflDir);
#ifdef _BLEND
	fixed4 skybox2 = texCUBE(_Cubemap2, reflDir);
	skybox = lerp(skybox, skybox2, _BlendRatio);
#endif
	col.rgb = lerp(col.rgb, skybox.rgb, saturate(fresnel * _ReflAmount + skybox.a * _SunIntensity));
#endif
#ifdef _WATERMODE_HIGH
	half4 reflUv = i.scrPos;
	reflUv.xy += worldNormal.xz * _ReflDistort;
	col.rgb = lerp(col.rgb, tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(reflUv)).rgb, fresnel * _ReflAmount);
#endif

#ifdef _USESHORELINE_ON
	half sss = 1.0f / (_WorldSpaceCameraPos.y + 1.0f);
	fixed4 shoreLineCol = tex2D(_ShoreLineTex, worldPos.xz *_ShoreLineTex_ST.xy * sss * 0.01 + worldNormal.xz * 0.08);
	col.rgb += _ShoreLineIntensity * shoreLineCol.rgb;
#endif
#ifdef _USEGROUNDTEX_ON
	fixed4 groundCol = tex2D(_GroundTex, i.uv1.xy);
	col.rgb = lerp(col.rgb, groundCol.rgb, _GroundIntensity);
#endif

	///
	/// Specular
	///
	half3 specLight = half3(worldLight.x, 0.3, worldLight.z);
	specLight = normalize(specLight);
	half3 halfDir = normalize(worldView + specLight);
	// Optimize pow function
	//half NdotH = pow(saturate(dot(halfDir, worldNormal)), _Gloss);
	half NdotH = saturate(dot(halfDir, worldNormal));
	NdotH = saturate(NdotH * _Gloss + (1.0 - _Gloss));
	NdotH *= NdotH;
	half spec = tex2D(_RampTex, half2(NdotH, NdotH)).g;
	col.rgb += _Specular.rgb * spec;

	///
	/// Reflection
	///
	half dotWorldView = worldView.y;
	half fresnel2 = clamp((_ReflStart - dotWorldView) / _ReflRange, 0.0, 1.0);
	col.rgb = lerp(col.rgb, _ReflColor.rgb, fresnel2 * fresnel2);

	///
	/// Fog
	///
#if defined (_FOGMODE_SCENE) || defined (_FOGMODE_CAMERA)
	float viewDist = length(i.viewPos.yz);
#ifdef _FOGMODE_SCENE
	float fog = 1 - saturate((viewDist)* unity_FogParams.z + unity_FogParams.w);
#endif
#ifdef _FOGMODE_CAMERA
	float fog = 1 - saturate(1.0 - (viewDist)* _ProjectionParams.w);
#endif
	col.rgb = lerp(col.rgb, unity_FogColor, fog);
#endif

	return col;
}

#endif	// WATER_COMMON_CG_INCLUDED