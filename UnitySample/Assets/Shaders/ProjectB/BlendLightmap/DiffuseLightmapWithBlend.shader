// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ProjectB/Diffuse LightMap (Blend)" {
    Properties {
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _MainTex ("Main (RGB)", 2D) = "white" {}
        _LightMap ("Light Map (RGB)", 2D) = "white" {}
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", float) = 2
		[KeywordEnum(HardLight, LinearLight, PinLight)] _BlendMode("Blend Mode", Float) = 0
		_BlendIntensity("Lightmap Intensity", Range(0, 1)) = 0.5
		_OutlineWidth("Outline Width", Range(0, 1)) = 0.1
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
    }

    SubShader {
        Tags { "RenderType" = "Opaque" }
        LOD 300
        Cull [_CullMode]
        
        Pass {
            Name "BASE"
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                // make fog work
                #pragma multi_compile_fog
                #pragma fragmentoption ARB_precision_hint_fastest

                #pragma multi_compile _BLENDMODE_HARDLIGHT _BLENDMODE_LINEARLIGHT _BLENDMODE_PINLIGHT

                #include "UnityCG.cginc"
				#include "BlendModeCG.cginc"

                struct a2v {
                    float4 pos : POSITION;
                    float2 uv1 : TEXCOORD0;
                    float2 uv2 : TEXCOORD1;
                };

                struct v2f { 
                    float4 pos : SV_POSITION;
                    float2 uv1  : TEXCOORD0;
                    float2 uv2 : TEXCOORD1;
                    UNITY_FOG_COORDS(2)
                };

                v2f vert(a2v i) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(i.pos);
                    o.uv1 = i.uv1;
                    o.uv2 = i.uv2;

                    UNITY_TRANSFER_FOG(o, o.pos);

                    return o;
                }

                uniform float4 _Color;
                uniform sampler2D _MainTex;
                uniform sampler2D _LightMap;
				float _BlendIntensity;

                float4 frag(v2f i) : COLOR {
                    float4 mainColor = tex2D(_MainTex, i.uv1) * _Color;
                    float3 lightmapColor = tex2D(_LightMap, i.uv2).rgb;
                    
					float3 blendColor = BlendColor(mainColor.rgb, lightmapColor);
					blendColor = lerp(mainColor.rgb, blendColor, _BlendIntensity);

                    float4 color = float4(blendColor, mainColor.a);
                    
                     // apply fog
                    UNITY_APPLY_FOG(i.fogCoord, color);

                    return color;
                }
            ENDCG
        }

		Pass {
			Name "OUTLINE"

			Cull Front

            CGPROGRAM
				#pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest

                #include "UnityCG.cginc"

                struct a2v {
                    float4 pos : POSITION;
					float3 normal : NORMAL;
					float4 color : COLOR;
                };

                struct v2f { 
                    float4 pos : SV_POSITION;
                };

				float _OutlineWidth;
				float4 _OutlineColor;

                v2f vert(a2v i) {
                    v2f o;

					float4 pos = mul(UNITY_MATRIX_MV, i.pos);
					float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, i.normal);
					//normal.z = -0.5;
					pos = pos + float4(normalize(normal), 0) * _OutlineWidth * i.color.r * (abs(pos.z) * 0.1 + 1.0);
					o.pos = mul(UNITY_MATRIX_P, pos);

                    return o;
                }

                float4 frag(v2f i) : COLOR {
					return float4(_OutlineColor.rgb, 1);
                }
			ENDCG
		}
    }

	SubShader {
        Tags { "RenderType" = "Opaque" }
        LOD 50
        Cull [_CullMode]
        
        Pass {
            Name "BASE"
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest

                #pragma multi_compile _BLENDMODE_HARDLIGHT _BLENDMODE_LINEARLIGHT _BLENDMODE_PINLIGHT

                #include "UnityCG.cginc"
				#include "BlendModeCG.cginc"

                struct a2v {
                    float4 pos : POSITION;
                    float2 uv1 : TEXCOORD0;
                };

                struct v2f { 
                    float4 pos : SV_POSITION;
                    float2 uv1  : TEXCOORD0;
                };

                v2f vert(a2v i) {
                    v2f o;
                    o.pos = UnityObjectToClipPos(i.pos);
                    o.uv1 = i.uv1;

                    return o;
                }

                uniform float4 _Color;
                uniform sampler2D _MainTex;
				float _ReflectionDiffuseIntensity;

                float4 frag(v2f i) : COLOR {
                    float4 mainColor = tex2D(_MainTex, i.uv1) * _Color;

                    float4 color = float4(mainColor.rgb * _ReflectionDiffuseIntensity, mainColor.a);

                    return color;
                }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
