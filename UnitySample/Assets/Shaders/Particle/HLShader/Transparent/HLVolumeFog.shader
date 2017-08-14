// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HL/Transparent/Volumetric Fog"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_FogDensity ("Fog Density", float) = 1
		_Intensity ("Intensity", float) = 1
		_Offset ("Offset Adjust", Range(0.1, 0.5)) = 0.3
		_MainTex ("Main Tex", 2D) = "white" {}
		_USpeed ("USpeed", Float) = 0
		_VSpeed ("VSpeed", Float) = 0
		_AddTex ("Mask Tex", 2D) = "white" {}
		//[HideInInspector]
		_DepthTex ("Depth Tex", 2D) = "black" {}

		[HideInInspector]_MatrixV0 ("_MatrixV4", Vector) = (1,2,3,4)
		[HideInInspector]_MatrixV1 ("_MatrixV1", Vector) = (1,2,3,4)
		[HideInInspector]_MatrixV2 ("_MatrixV2", Vector) = (1,2,3,4)
		[HideInInspector]_MatrixV3 ("_MatrixV3", Vector) = (1,2,3,4)
	}

	CGINCLUDE
	//
	ENDCG

	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType"="Transparent"}
		Pass
		{
			Tags { "LIGHTMODE"="Always" }
			Lighting Off
			Fog { Mode Off }
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			ZWrite Off

			CGPROGRAM
			#include "../HLInclude.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			//#pragma multi_compile DISABLE STATICFOG REALTIMEFOG
			#pragma multi_compile DISABLE VOLUMETRICFOGUNITY VOLUMETRICFOGHL
			#pragma multi_compile EXP2FOG EXPFOG
			#pragma multi_compile MATRIXPARAM NOMATRIXPARAM
			#pragma target 2.0

			//#define DISABLE
			//#define EXP2FOG

			uniform float _FogDensity;
			uniform float _Offset;
			
			#if defined(DISABLE)
			#elif defined(VOLUMETRICFOGUNITY)
				uniform sampler2D _CameraDepthTexture;
			#elif defined(VOLUMETRICFOGHL)
				uniform sampler2D _DepthTex;
			#endif

			struct appdata
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : POSITION;
                float2 uv[2] : TEXCOORD0;
				#if !defined(DISABLE)
				float4 pos2 : TEXCOORD2;
				#endif
				fixed4 color : COLOR;
			};

			#if defined(EXP2FOG)
			inline float CalcFogFactor(float dist, const float density)
			{
			  dist = max(0, dist);
			  const float log2e = 1.442695; // = 1/ln2
			  float d = density * dist;
			  return 1.0 - saturate(exp2(- d * d * log2e));
			}
			#elif defined(EXPFOG)
			inline float CalcFogFactor(float dist, const float density)
			{
			  dist = max(0, dist);
			  const float log2e = 1.442695; // = 1/ln2
			  float d = density * dist;
			  return 1.0 - saturate(exp2(- d * log2e));
			}
			#endif
			
			#if defined(MATRIXPARAM)
			uniform float4 _MatrixV0;
			uniform float4 _MatrixV1;
			uniform float4 _MatrixV2;
			uniform float4 _MatrixV3;
			#endif

			v2f vert(appdata i)
			{
				v2f o;
				o.color = i.color * _Color;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv[0] = TRANSFORM_TEX(i.uv, _MainTex);
				o.uv[1] = TRANSFORM_TEX(i.uv, _AddTex);

				o.uv[0] = Calculate_UVAnim(o.uv[0], _USpeed, _VSpeed);
				
				float4x4 mat = UNITY_MATRIX_MVP;
				#if defined(DISABLE)
					;
				#elif defined(VOLUMETRICFOGUNITY)
					o.pos2 = ComputeScreenPos(o.pos);
				#elif defined(VOLUMETRICFOGHL)
					#if defined(MATRIXPARAM)
						mat[0] = _MatrixV0;
						mat[1] = _MatrixV1;
						mat[2] = _MatrixV2;
						mat[3] = _MatrixV3;
						float4 posTemp = mul(mat, i.vertex);
						o.pos2 = ComputeScreenPos(posTemp);
					#elif defined(NOMATRIXPARAM)
						o.pos2 = ComputeScreenPos(o.pos);
					#endif
				#endif

				return o;
			}

			fixed4 frag(v2f i) : COLOR0
			{
				fixed4 color = i.color * _Intensity;
				fixed4 mainColor = tex2D(_MainTex, i.uv[0]);
				fixed4 maskColor = tex2D(_AddTex, i.uv[1]);
				mainColor *= maskColor;
				color.a *= mainColor.a;
				
				float vFogFactor = 1.0f;
				#if defined(DISABLE)
					vFogFactor = 0.3f;
				#elif defined(VOLUMETRICFOGUNITY)
					float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.pos2));
					float depthEye = DECODE_EYEDEPTH(depth);
					//float d = depthEye - DECODE_EYEDEPTH(i.pos2.z/i.pos2.w);
					float d = depthEye - i.pos2.z - _Offset;
					vFogFactor = CalcFogFactor(d, _FogDensity);
				#elif defined(VOLUMETRICFOGHL)
					fixed4 dec = tex2D(_DepthTex, i.pos2.xy/i.pos2.w);
					//float depthEye = DecodeFloatRGBA(dec) * 100.0f;
					float depthEye = DecodeFloatRG(dec.rg) * 100.0f;
					float d = depthEye - i.pos2.z - _Offset;
					vFogFactor = CalcFogFactor(d, _FogDensity);
				#endif
				
				color.a *= vFogFactor;
				return color;
			}
	
			ENDCG
		} 
	}

	Fallback Off
	//Fallback "VertexLit"
}