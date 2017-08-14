#ifndef HL_INCLUDE_SHADER
#define HL_INCLUDE_SHADER
 
#include "UnityCG.cginc"

	float4 _Color;
	float _Intensity;
	sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _AddTex;
	float4 _AddTex_ST;
	
	float _UVRotateSpeed;
	float _USpeed;
	float _VSpeed;
	float _USpeed1;
	float _VSpeed1;

	half _ForceX;
	half _ForceY;
	float _HeatTime;
	
	inline float2 Calculate_UVAnim(float2 uv, float uSpeed, float vSpeed)
	{
		float time = _Time.z;
		float absUOffsetSpeed   = abs(uSpeed);
		float absVOffsetSpeed   = abs(vSpeed);

		if (absUOffsetSpeed > 0)
		{
			uv.x += frac(time * uSpeed);
		}

		if (absVOffsetSpeed > 0)
		{
			uv.y += frac(time * vSpeed);
		}

		return uv;
	}

	inline float2 Calculate_UVRotate(float2 uv, float uvRotateSpeed)
	{
		const half TWO_PI = 3.14159 * 2;
		const half2 VEC_CENTER = half2(0.5h, 0.5h);

		float time = _Time.z;
		float absUVRotSpeed = abs(uvRotateSpeed);
		half2 finaluv = uv;
		if (absUVRotSpeed > 0)
		{
			finaluv -= VEC_CENTER;
			half rotation = TWO_PI * frac(time * uvRotateSpeed);
			half sin_rot = sin(rotation);
			half cos_rot = cos(rotation);
			finaluv = half2(
				finaluv.x * cos_rot - finaluv.y * sin_rot,
				finaluv.x * sin_rot + finaluv.y * cos_rot);
			finaluv += VEC_CENTER;
		}
		uv = finaluv;
		return uv;
	}

	inline float2 Calculate_NoiseFromTex(float2 uv, sampler2D addTex)
	{
		float4 time = _Time;
		half offsetColor1 = tex2D(addTex, uv + frac(time.xz * _HeatTime));
		half offsetColor2 = tex2D(addTex, uv + frac(time.yx * _HeatTime));
		uv.x += (offsetColor1 - 0.5h) * _ForceX;
		uv.y += (offsetColor2 - 0.5h) * _ForceY;
		return uv;
	}

#endif
