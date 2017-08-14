// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MobileSpecular" {
   Properties {
		[Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 2

		_Color ("Main Color", Color) = (1,1,1,1)
        _SpecColor ("Specular", Color) = (0.2, 0.2, 0.2, 0)
        _Glossiness ("Smoothness", Range (0, 1)) = 0.078125
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BumpMapTex ("Normalmap (RGB) Gloss (A) Use Texture Mode", 2D) = "bump" {}

        _NoiseMap ("Noise Map", 2D) = "black" {}
        _BumpTiling("Noise Tiling", Vector) = (0, 0, 0, 0)
        _BumpDirection("Noise Direction", Vector) = (0, 0, 0, 0)

        _AlphaPower("Alpha Power (Normalmap)", Range(0, 1)) = 0.5
        _NoiseScale("Noise Map Scale", Float) = 1.0
        _NoiseFactor("Noise Factor", Range(0, 3)) = 0.1

        _EmissionMap ("Emission Map", 2D) = "black" {}
        _EmissionColor ("EmissionColor", Color) = (0, 0, 0)

        _Cutoff("Cut Off", Range(0, 1)) = 0.1
		_GroundColorFac("Ground Color Fac", Range(1, 10)) = 1

		[HideInInspector] _SrcBlend ("_SrcBlend", Float) = 1.0
		[HideInInspector] _DstBlend ("_DstBlend", Float) = 0.0
		[HideInInspector] _ZWrite ("_ZWrite", Float) = 1.0
		
		//_ScenePointLightColor("Scene Point Light Color", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest"  }
		LOD 250
		

		Pass {
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }
			Cull [_Cull]
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite]

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase

			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON  
			#pragma multi_compile_fwdadd_fullshadows

			#pragma multi_compile __ FLOWING

			#pragma shader_feature _NORMALMAP_ON
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _ALPHABLEND_ON
			#pragma shader_feature _NOISEMAP_ON
			#pragma shader_feature _EMISSION
			#pragma shader_feature __ POINT_LIGHT_COLOR1 POINT_LIGHT_COLOR2

			#pragma skip_variants DIRLIGHTMAP_COMBINED DIRECTIONAL_COOKIE LIGHTMAP_SHADOW_MIXING POINT_COOKIE SHADOWS_CUBE SHADOWS_DEPTH SHADOWS_SHADOWMASK SHADOWS_SOFT SPOT

			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"

			#define UNITY_PASS_FORWARDBASE
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			fixed4 _Color;
			fixed4 _SpecularColor;
			fixed4 _BloomPower;
			half _Glossiness;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			//sampler2D _BumpMap;
			sampler2D _BumpMapTex;

			float _BumpScale;

			sampler2D _NoiseMap;
			float4  _NoiseMap_ST;
			float4  _BumpTiling;
			float4  _BumpDirection;

			float _AlphaPower;
			float _NoiseScale;
			float _NoiseFactor, _GroundColorFac;

			sampler2D _EmissionMap;
			fixed4 _EmissionColor;

			uniform fixed4 _ScenePointLightColor, _ScenePointLightColor1, _ScenePointLightColor2, _OtherLightColor, _ShadowColor;
			uniform fixed3 _OtherLightDir;

			fixed3 otherSpecColor, _OtherLightHalfDir;

			fixed _Cutoff, _FlowBlend;

			inline fixed3 GetNoise(sampler2D bumpMap, half4 coords, float scale) {
				return (UnpackScaleNormal(tex2D(bumpMap, coords.xy), scale) + UnpackScaleNormal(tex2D(bumpMap, coords.zw), scale)) * 0.5;
			}

			inline fixed4 LightingMobileBlinnPhong (fixed3 Albedo, fixed3 Specular, fixed3 Normal, half Smoothness, 
					half Occlusion, fixed Alpha, fixed3 lightDir, fixed3 halfDir, fixed atten) {
				fixed diff = max (0, dot (Normal, lightDir));
				fixed nh = max (0, dot (Normal, halfDir));
				fixed spec = pow (nh, Specular*128) * Smoothness;

				fixed4 c;
				c.rgb = (Albedo * (_LightColor0.rgb * diff) + _LightColor0.rgb * spec * Occlusion) * atten;
				return c;
			 }

			struct appdata_t {  
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1; 

				float4 tangent : TANGENT;
			};  

			struct v2f {
				float4 pos : SV_POSITION;
				float2 texcoord : TEXCOORD0; // _MainTex

				fixed3 worldNormal : NORMAL;
				fixed3 worldPos : TEXCOORD1;
				fixed3 worldTangent : TANGENT;
				fixed3 worldBinormal : TEXCOORD2;
				fixed3 vlight : TEXCOORD3; // ambient/SH/vertexlights

				UNITY_SHADOW_COORDS(4)
				UNITY_FOG_COORDS(5)

				#if LIGHTMAP_ON
				float4 lmap : TEXCOORD6;
				#endif
			};

			v2f vert (appdata_t v) {
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				o.pos = UnityObjectToClipPos (v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				o.worldBinormal = cross(o.worldNormal, o.worldTangent) * tangentSign;

				#if LIGHTMAP_ON
				o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				// SH/ambient and vertex lights

				float3 shlight = ShadeSH9 (float4(o.worldNormal, 1.0));
				o.vlight = shlight;
				o.vlight += saturate(-o.worldNormal.y) * (_GroundColorFac - 1) * unity_AmbientGround;

				#if LIGHTMAP_OFF
				UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy);
				#else
				o._ShadowCoord.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
				return o;
			}

			fixed4 frag (v2f IN) : SV_Target {
				fixed4 tex = tex2D(_MainTex, IN.texcoord) * _Color;

				fixed Alpha = tex.a;
				// alpha test
				#if _ALPHATEST_ON
					clip (Alpha - _Cutoff);
				#endif

				float3 worldPos = IN.worldPos;
				#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				#if _NORMALMAP_ON
					_OtherLightHalfDir = normalize(worldViewDir + _OtherLightDir); // 另外一盏灯
				#endif

				worldViewDir = normalize(worldViewDir + lightDir);

				fixed3 Albedo = tex.rgb;
				fixed3 Specular = _SpecColor;
				
				#if _NORMALMAP_ON
					fixed4 normalMap = tex2D(_BumpMapTex, IN.texcoord);
					fixed3 Normal = normalMap.rgb * 2 - 1;

					#if _NOISEMAP_ON
						float4 bumpCoords = (IN.texcoord.xyxy + _Time.xxxx * _BumpDirection.xyzw) * _BumpTiling.xyzw;       
						fixed3 Noise =
						#if FLOWING
							_FlowBlend *
						#endif 
							GetNoise(_NoiseMap, bumpCoords, _NoiseScale);

						Normal += Noise * fixed3(1,0,1) * _NoiseFactor;
					#endif
					Normal = normalize(Normal);

					fixed3 worldN;
					worldN.x = dot(fixed3(IN.worldTangent.x, IN.worldBinormal.x, IN.worldNormal.x), Normal);
					worldN.y = dot(fixed3(IN.worldTangent.y, IN.worldBinormal.y, IN.worldNormal.y), Normal);
					worldN.z = dot(fixed3(IN.worldTangent.z, IN.worldBinormal.z, IN.worldNormal.z), Normal);
					Normal = worldN;

					half Occlusion = saturate(pow(normalMap.a, (1 - _AlphaPower) * 2));
				#else
					fixed3 Normal = IN.worldNormal;
				#endif

				half Smoothness = _Glossiness;
				
				// compute lighting & shadowing factor
				#ifndef LIGHTMAP_ON
					UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
				#else
					fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy);
					fixed3 lm = DecodeLightmap (lmtex);
					#if LIGHTMAP_SHADOW_MIXING 
						float atten = UnityComputeForwardShadows(IN._ShadowCoord, worldPos, 0);
					#else
						float atten = lm.r;
						/*
						float amax = 0.7, amin = 0.1;
						if(atten > amax) {
							atten = 1;
						}
						else if(atten > amin) {
							atten = (atten - amin) / (amax - amin);
						}
						else {
							atten = 0;
						}
						*/
					#endif
				#endif
							
				fixed4 c = 0;
				otherSpecColor = 0;

				Albedo.rgb *= _BloomPower.x;

				c.rgb = Albedo * IN.vlight;
				#if _NORMALMAP_ON
					float dist = distance(_WorldSpaceCameraPos, IN.worldPos);
					Smoothness *= (1 - saturate((dist - 10) / 5));  // no specular light if the object is too far away

					if(Smoothness > 0.1)
					{
						fixed otherSpec = pow (max (0, dot (Normal, _OtherLightHalfDir)), Specular*128) * Smoothness;
						otherSpecColor += _OtherLightColor.rgb * _OtherLightColor.a * otherSpec * Occlusion;
						c.rgb += otherSpecColor;

						Smoothness *= _BloomPower.y;
						fixed4 lighting = LightingMobileBlinnPhong (Albedo, Specular, Normal, Smoothness, Occlusion, Alpha, lightDir, worldViewDir, atten);
						c.rgb += lighting.rgb;
					}
					else {
						c.rgb += Albedo * _LightColor0.rgb * max (0, dot (Normal, lightDir)) * atten;
					}
				#else
					c.rgb += Albedo * _LightColor0.rgb * max (0, dot (Normal, lightDir)) * atten;	
				#endif

				// add shadow Color
				c.rgb = lerp(c.rgb, c.rgb * atten + (1 - atten) * _ShadowColor.rgb * Albedo,  _ShadowColor.a * Alpha);

				// lightmaps
				#ifdef LIGHTMAP_ON
					//lm = LinearToGammaSpace(lm) /2;
					c.rgb += Albedo * lm.b *
					#if POINT_LIGHT_COLOR1
						_ScenePointLightColor1
					#elif POINT_LIGHT_COLOR2
						_ScenePointLightColor2
					#else
						_ScenePointLightColor
					#endif
					 * saturate(atten + lm.b * 0.5);
				#endif

				#if _EMISSION
					c.rgb += tex2D(_EmissionMap, IN.texcoord).rgb * _EmissionColor.rgb;
				#endif

				// c.rgb *= c.a;
				UNITY_APPLY_FOG(IN.fogCoord, c);

				#ifdef _ALPHABLEND_ON
					c.a = tex.a;
				#endif

				return c;
			}
			ENDCG
		}

	// ---- forward rendering additive lights pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardAdd" }
		ZWrite Off
		Blend [_SrcBlend] One
        ColorMask RGB

		CGPROGRAM
		// compile directives
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 3.0
		#pragma multi_compile_fog
		#pragma multi_compile_fwdadd_fullshadows
		#pragma shader_feature _ALPHATEST_ON
		#pragma shader_feature _ALPHABLEND_ON

		#define UNITY_PASS_FORWARDADD
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#include "AutoLight.cginc"
			
		fixed4 _Color;

		sampler2D _MainTex;
		float4 _MainTex_ST;

		fixed _Cutoff;

		struct appdata_t {  
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1; 

			float4 tangent : TANGENT;
		};  

		struct v2f {
			float4 pos : SV_POSITION;
			float2 texcoord : TEXCOORD0; // _MainTex

			fixed3 worldNormal : NORMAL;
			fixed3 worldPos : TEXCOORD1;

			UNITY_SHADOW_COORDS(2)
			UNITY_FOG_COORDS(3)
		};

		v2f vert (appdata_t v) {
			v2f o;
			UNITY_INITIALIZE_OUTPUT(v2f,o);
			o.pos = UnityObjectToClipPos (v.vertex);
			o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			o.worldNormal = UnityObjectToWorldNormal(v.normal);

			UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy);
			UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
			return o;
		}

		fixed4 frag (v2f IN) : SV_Target {
			fixed4 tex = tex2D(_MainTex, IN.texcoord) * _Color;
			fixed Alpha = tex.a;               

			// alpha test
			#if _ALPHATEST_ON
				clip (Alpha - _Cutoff);
			#endif

			float3 worldPos = IN.worldPos;
			#ifndef USING_DIRECTIONAL_LIGHT
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
			#else
				fixed3 lightDir = _WorldSpaceLightPos0.xyz;
			#endif

			// compute lighting & shadowing factor
			UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)

			fixed4 c = 0;
			c.rgb += tex.rgb * _LightColor0.rgb * max (0, dot (IN.worldNormal, lightDir)) * atten;
			#if _ALPHABLEND_ON
				c.a = Alpha;
			#endif
			return c;
		}
		ENDCG

	}

	Pass {
		Name "Meta"
		Tags { "LightMode" = "Meta" }
		Cull Off

		CGPROGRAM
		// compile directives
		#pragma vertex vert_surf
		#pragma fragment frag_surf
		#pragma target 3.0
		#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
		#pragma shader_feature _ALPHATEST_ON		

		#include "HLSLSupport.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityShaderUtilities.cginc"
		#define UNITY_PASS_META
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#include "UnityPBSLighting.cginc"		
		#include "UnityMetaPass.cginc"

		sampler2D _MainTex;
		float4 _MainTex_ST;

		// vertex-to-fragment interpolation data
		struct v2f_surf {
			float4 pos : SV_POSITION;
		};

		// vertex shader
		v2f_surf vert_surf (appdata_full v) {
			v2f_surf o;
			UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
			return o;
		}

		// fragment shader
		fixed4 frag_surf (v2f_surf IN) : SV_Target {
			UnityMetaInput metaIN;
			UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
			metaIN.Albedo = tex2D(_MainTex, IN.pos);
			metaIN.Emission = 0;
			return UnityMetaFragment(metaIN);
		}
		
		ENDCG
	}

	}
	FallBack "Legacy Shaders/Transparent/Cutout/Diffuse"
	CustomEditor "CustomMobileSpecularShaderGUI"
}
