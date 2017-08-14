// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FX/SeaWater" { 
Properties {
	
	//_MainTex ("Fallback texture", 2D) = "black" {}	
	
	
	u_1DivLevelWidth ("u_1DivLevelWidth", Float) = 0
	u_1DivLevelHeight ("u_1DivLevelHeight", Float) = 0
	WAVE_HEIGHT("WAVE_HEIGHT", Float) = 0
	WAVE_MOVEMENT("WAVE_MOVEMENT", Float) = 0

	SEA_DARK("SEA_DARK", Color) = (0.5,0.5,0.5,0.5)
	SEA_LIGHT("SEA_LIGHT", Color) = (0.5,0.5,0.5,0.5)
	u_lightPos("u_lightPos", Vector) = (0.5,0.5,0.5,0.5)
	
	normal0("normal0", 2D) = "black" {}	
	depthmap("depthmap", 2D) = "white" {}	
	//#endif

	u_reflectionFactor("u_reflectionFactor", Float) = 0
	
	_TimeScale("TimeScale", Float) = 1

	//#ifdef LIGHTMAP
	//#endif
	
	
} 


//#ifndef SIMPLE
//	#define LIGHTMAP
//	#define REFLECTION
//#endif // SIMPLE
//
//#ifdef FOAM
//	#ifndef SIMPLE
//		#define USE_FOAM
//	#endif // SIMPLE
//#endif // FOAM





//uniform   mat4 u_mvp;


CGINCLUDE

//#pragma exclude_renderers d3d11 xbox360
	
	#include "UnityCG.cginc"

	struct appdata {
		float4 a_pos : POSITION;
		float2 a_uv0 : TEXCOORD0;
		float4 a_color : COLOR;
	};


	// interpolator structs	
	struct v2f_simple
	{
		float4 v_Position : SV_POSITION;
		float2 v_depthUv : TEXCOORD0;
		float2 v_bumpUv1 : TEXCOORD1;
		float4 v_wave : TEXCOORD2;
		float4 v_darkColor:COLOR0;
		float4 v_lightColor:COLOR1;
		float v_reflectionPower : TEXCOORD4;
	};	

	
	//uniform float u_time;
	uniform half u_1DivLevelWidth;
	uniform half u_1DivLevelHeight;
	uniform half WAVE_HEIGHT;
	uniform half WAVE_MOVEMENT;

	uniform half4 SEA_DARK;
	uniform half4 SEA_LIGHT;

	uniform half4 u_lightPos;
	
	uniform half _TimeScale;
								
	
	v2f_simple vert(appdata v)
	{
		float _realTime = _TimeScale * _Time.y;
	   
		v2f_simple o;
		

		float4 pos = v.a_pos;
	
		// Calculate new vertex position with wave
		float animTime = v.a_uv0.y + _realTime;
		
		float scaleFactor = 1.0 - (cos(_realTime * 0.2) * 0.5 + 0.5) * 0.1;
		animTime += sin((v.a_pos.x + v.a_pos.z * sin((_realTime + v.a_pos.x) * 0.01)) * 0.4 * scaleFactor + _realTime * 0.2) * 0.5 + 0.5;

		float wave = cos(animTime);
		float waveHeightFactor = (wave + 1.0) * 0.5;
		pos.z += WAVE_MOVEMENT * waveHeightFactor * v.a_color.g * v.a_color.b;
		pos.y += wave * WAVE_HEIGHT * v.a_color.b;
		o.v_Position = UnityObjectToClipPos(pos);
		
		// Water alpha
		float maxValue = 0.55;//0.5;
		//o.v_wave.x = 1.0 - (v.a_color.a - maxValue) * (1.0 / maxValue);
		o.v_wave.x = 1.0 - (0 - maxValue) * (1.0 / maxValue);
		o.v_wave.x = o.v_wave.x * o.v_wave.x;
		o.v_wave.x = o.v_wave.x * 0.8 + 0.2;
		o.v_wave.x -= wave * v.a_color.b * 0.1;
		o.v_wave.x = min(1.0, o.v_wave.x);

		// UV coordinates
		float2 texcoordMap = float2(v.a_pos.x * u_1DivLevelWidth, v.a_pos.z * u_1DivLevelHeight) * 4.0;
		o.v_bumpUv1.xy = texcoordMap + float2(0.0, _realTime * 0.005) * 1.5;			// bump uv
		o.v_depthUv = v.a_uv0;
		
		float3 lightDir = normalize(float3(-1.0, 0.0, 1.0));
		float3 lightVec = normalize(u_lightPos - pos.xyz);
		o.v_wave.y = (1.0 - abs(dot(lightDir, lightVec)));
		o.v_wave.y = o.v_wave.y * 0.2 + (o.v_wave.y * o.v_wave.y) * 0.8;
		o.v_wave.y = clamp(o.v_wave.y + 1.1 - (length(u_lightPos - pos.xyz) * 0.008), 0.0, 1.0);
		o.v_wave.w = (1.0 + (1.0 - o.v_wave.y * 0.5) * 7.0);


		// Blend factor for normal maps
	    o.v_wave.z = (cos((v.a_pos.x + _realTime) * v.a_pos.z * 0.003 + _realTime) + 1.0) * 0.5;

		// Calculate colors
		//float blendFactor = 1.0 - min(1.0, v.a_color.a * 1.6);
		float blendFactor = 1.0 - min(1.0, 0 * 1.6);
		
//		float tx = v.a_pos.x * u_1DivLevelWidth;
//		float ty = v.a_pos.z * u_1DivLevelHeight;
//		
//		float tmp = (tx * tx + ty * ty) / (0.75 * 0.75);
//		float blendFactorMul = step(1.0, tmp);
//		tmp = pow(tmp, 3.0);
//		// Can't be above 1.0, so no clamp needed
//		float blendFactor2 = max(blendFactor - (1.0 - tmp) * 0.5, 0.0);
//		blendFactor = lerp(blendFactor2, blendFactor, blendFactorMul);

		o.v_darkColor = SEA_DARK;
		o.v_lightColor = SEA_LIGHT;

		//o.v_reflectionPower = ((1.0 - v.a_color.a) + blendFactor) * 0.5;//blendFactor;
		o.v_reflectionPower = ((1.0 - 0) + blendFactor) * 0.5;//blendFactor;
		// Put to log2 here because there's pow(x,y)*z in the fragment shader calculated as exp2(log2(x) * y + log2(z)), where this is is the log2(z)
		o.v_reflectionPower = log2(o.v_reflectionPower);
				
		return o;

	}
	uniform sampler2D normal0;
	uniform sampler2D depthmap;
	uniform float u_reflectionFactor;

	
	//uniform sampler2D _MainTex;

	half4 frag( v2f_simple i ) : color
	{		
		half4 baseColor;
		
		float4 normalMapValue = tex2D(normal0, i.v_bumpUv1.xy);
		float4 depthMapValue = tex2D(depthmap,i.v_depthUv.xy);
	    baseColor = lerp(i.v_lightColor, i.v_darkColor, (normalMapValue.x * i.v_wave.z) + (normalMapValue.y * (1.0 - i.v_wave.z)));
	    baseColor.a = depthMapValue.r;
	    //baseColor.a = i.v_wave.x;
		//#ifdef REFLECTION
			float reflectValue = exp2(log2(((normalMapValue.z * i.v_wave.z) + (normalMapValue.w * (1.0 - i.v_wave.z))) * i.v_wave.y) * i.v_wave.w + i.v_reflectionPower) * u_reflectionFactor;
			baseColor += half4(reflectValue,reflectValue,reflectValue,reflectValue);
			//baseColor = half4(1,1,1,1)*reflectValue;	
		//#endif
		
		//baseColor.a = tex2D(lightTex, i.v_worldPos).b;
//		#ifdef REFLECTION
//			return half4(1,0,0,1);
//		#else
//			return half4(0,1,0,1);
//		#endif
		//baseColor.a = 0.8;
		//return float4(tex2D(lightTex, i.v_worldPos).rgb,1);
		return baseColor;
	}
			
ENDCG



Subshader 
{ 	
	Tags {"RenderType"="Transparent" "Queue"="Transparent+10"}
	
	Lod 200
	ColorMask RGB
	
	Pass {
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest LEqual
			ZWrite On
			Cull Off
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile REFLECTION NOREFLECTION	
			#pragma multi_compile FOAM NOFOAM		  						  			
			ENDCG
	}	
}

Fallback "Transparent/Diffuse"
}
