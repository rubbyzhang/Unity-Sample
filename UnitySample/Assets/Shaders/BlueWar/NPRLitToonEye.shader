Shader "BlueWar/NPRLitToonEye"
{
    Properties
    {
        [HideInInspector]_Fade("Fade", Range(0, 1)) = 1.0

        [Header(Shader Properties)]
            _Color("Color", Color) = (1, 1, 1, 0.2)
            _MainTex("Base (RGB)", 2D) = "white" {}
            _EnvTex("Environment Tex", 2D) = "black" {}

        [Header(Render State)]
            [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Float) = 5
            [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Float) = 10

        [Header(Shader Feature Lists)]
            [Toggle(USE_PARALLAXOFFSET)] _UseParallaxOffset("Use ParallaxOffset", Float) = 0
            [Toggle(USE_FAKEREFLECTION)] _UseFakeReflection("Use FakeReflection", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "ForceNoShadowCasting" = "True" }

        LOD 150

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            Cull Back ZTest LEqual Blend [_SrcBlend] [_DstBlend] ZWrite off

            Stencil {
                Ref 128
                WriteMask 128
                Comp Always
                Pass Replace
                ZFail Keep
            }

            CGPROGRAM
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 3.0

            #pragma shader_feature _ USE_PARALLAXOFFSET
            #pragma shader_feature _ USE_FAKEREFLECTION

            #pragma multi_compile_fwdbase
            #pragma multi_compile _ USE_LOCALLIGHT

            #pragma vertex   NPRToonCharacterEyeVS
            #pragma fragment NPRToonCharacterEyePS
            #include "NPRToonStandard.cginc"

            sampler2D _EnvTex;
            float4    _EnvTex_ST;

            v2f_standard NPRToonCharacterEyeVS(appdata_full v)
			{
			    NPRTOON_VS_COMMON(v2f_standard, o);
			#if USE_FAKEREFLECTION
			    o.uv.zw = TRANSFORM_TEX(v.texcoord, _EnvTex);
			#endif
			    return o;
			}

			fixed4 NPRToonCharacterEyePS(v2f_standard IN): SV_Target
			{
				half3 lightDir = ToonLightDir().xyz;
				half3 normal = normalize(IN.worldNormal); //opt : skip using normalize for performance, wait for artist's feedback
                fixed4 lightColor = ToonLightColor();

			    //lighting ndl
			    half ndl = step(0, dot(normal, lightDir));
			    half3 lighting = IN.vlight.rgb + max(ndl, 0.75f) * lightColor.rgb;

			#if USE_PARALLAXOFFSET
			    float2 uv = IN.worldCamDir * 0.15f + IN.uv.xy;
			#else
				float2 uv = IN.uv.xy;
			#endif

			    fixed4 basecolor = tex2D(_MainTex, uv);
			    lighting = (basecolor.xyz) * lighting * _Color.rgb;

			#if USE_FAKEREFLECTION
			    fixed4 reflection = fixed4(tex2D(_EnvTex, IN.worldCamDir * 0.3f + IN.uv.zw).rgb, _Fade);
			    lighting = lerp(reflection.rgb * lightColor.a, lighting.rgb, basecolor.a);
			#endif

			    return fixed4(lighting.rgb, basecolor.a * _Fade);
			}
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry+501" "ForceNoShadowCasting" = "True" }

        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            Cull Back ZTest LEqual Blend SrcAlpha OneMinusSrcAlpha ZWrite off

            Stencil {
                Ref 128
                WriteMask 128
                Comp Always
                Pass Replace
                ZFail Keep
            }

            CGPROGRAM
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 3.0

            #pragma multi_compile_fwdbase
            #pragma vertex   NPRToonCharacterStandardVS
            #pragma fragment NPRToonCharacterEyePS
            #include "NPRToonStandard.cginc"

			fixed4 NPRToonCharacterEyePS(v2f_standard IN): SV_Target
			{
			    fixed4 basecolor = tex2D(_MainTex, IN.uv.xy);
			    return fixed4(basecolor.rgb * _Color.rgb, basecolor.a * _Fade);
			}

            ENDCG
        }
    }

    FallBack "Diffuse"

    CustomEditor "CustomMaterialEditor"
}