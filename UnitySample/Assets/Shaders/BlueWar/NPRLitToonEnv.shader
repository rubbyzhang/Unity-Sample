Shader "BlueWar/NPRLitToonEnv"
{
    Properties
    {
        [Header(Shader Properties)]
            _LightThreshold("Light Threshold", Range(0, 1)) = 0.5
            _LightSmoothness("Light Smoothness", Range(0, 1)) = 0.5
            _OutlineColor("Outline Color", Color) = (0, 0, 0, 0)
            _Outline("Outline Width", Range(0, 10)) = 0.05
            _GlossyMatcap("Glossy Matcap", 2D) = "" {}
            _MainTex("Base (RGB)", 2D) = "white" {}
            _DecalTex("Decal (RGB)", 2D) = "black" {}
            DecalUV("DecalUV", Vector) = (1, 1, 1, 1) //center_xy[0,0]-[1,1], tile_zw,[0,+INF]
            _ToonMap("ToonMap (RGB)", 2D) = "white" {}
            _ShadingMask("ShadingMask (RGB)", 2D) = "white" {}
            SpecularPower("SpecularPower", Float) = 1.0
            SpecularFactor("SpecularFactor", Range(0, 1)) = 1.0
            RimGeneral("Rim General", Range(0, 1)) = 0.5
            RimPower("Rim Power", Float) = 1

        [Header(Shader Feature Lists)]
            [Toggle(FIXED_OUTLINESIZE)] _EnableFixedOutline("Fixed Outline Size?", Float) = 1
            [Toggle(USE_SMOOTHEDMESH)] _UseSmoothedMesh("Use Smoothed Mesh?", Float) = 0
            [Toggle(USE_AUTOLINECOLOR)] _UseAutoOutlineColor("Use Auto calculated outline color?", Float) = 1
            [Toggle(USE_DECAL)] _UseDecal("Use Decal?", Float) = 0
            [Toggle(USE_SPECULARLIGHTING)] _UseSpecularLighting("Use Specular Lighting?", Float) = 1
            [Toggle(USE_RIMLIGHTING)] _UseRimLighting("Use Rim Lighting?", Float) = 1
            [Toggle(USE_GLOSSYREFLECTION)] _UseGlossyReflection("Use Glossy Reflection?", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry+401" }

        LOD 150

        // pass for directional light shading
        Pass
        {
            Name "FORWARD"

            Tags { "LightMode" = "ForwardBase" }

            Cull Back ZTest LEqual Blend off ZWrite on

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

            #pragma shader_feature _ USE_DECAL
            #pragma shader_feature _ USE_GLOSSYREFLECTION
            #pragma shader_feature USE_RIMLIGHTING _
            #pragma shader_feature USE_SPECULARLIGHTING _

            #pragma multi_compile_fwdbase
            #pragma multi_compile _ USE_LOCALLIGHT
			#pragma multi_compile NOTHINGSPECIAL VERTEXLIGHT_ON

            #pragma vertex   NPRToonCharacterStandardVS
            #pragma fragment NPRToonCharacterStandardPS
            #include "NPRToonStandard.cginc"
            ENDCG
        }

        // back-facing outline
        Pass
        {
        	NAME "OUTLINE"

            Cull Front ZTest LEqual Blend off

            CGPROGRAM
            #pragma fragmentoption ARB_precision_hint_fastest

            #pragma shader_feature FIXED_OUTLINESIZE _
            #pragma shader_feature USE_SMOOTHEDMESH _
            #pragma shader_feature USE_AUTOLINECOLOR _
            
            #pragma vertex   vert
            #pragma fragment frag
			#include "NPRToonLighting.cginc"

			struct v2f
			{
			    float4 pos: SV_POSITION;
			    float2 uv: TEXCOORD0;
			};

			sampler2D _MainTex;
			float     _Outline;
			fixed4    _OutlineColor;

			v2f vert(appdata_full v)
			{
			    v2f o;

			#if USE_SMOOTHEDMESH
			    float3 normal = mul((float3x3) UNITY_MATRIX_IT_MV, v.tangent.xyz);
			#else
			    float3 normal = mul((float3x3) UNITY_MATRIX_IT_MV, v.normal);
			#endif

			    // Camera-independent outline size if dist is not 1
			    float4 pos = v.vertex;
                pos.xyz = UnityObjectToViewPos(v.vertex);

			#if FIXED_OUTLINESIZE
			    float dist = distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
			#else
                float4 hpos = UnityObjectToClipPos(v.vertex);
			    float dist = max(0, 1 - hpos.z/hpos.w); // 1.0;
			#endif

			    pos = pos + float4(normalize(normal), 0) * _Outline * dist * v.color.a;

			    o.pos = mul(UNITY_MATRIX_P, pos);
			    o.uv = v.texcoord;

			    return o;
			}

			float4 frag(v2f IN): COLOR
			{
				float luminance = ToonLightColor().a;

			#if USE_AUTOLINECOLOR
			    float3 c = 0.36 * tex2D(_MainTex, IN.uv).rgb;
			    return float4(lerp(c.rgb, _OutlineColor.rgb, _OutlineColor.a) * luminance, 0);
			#else
				return float4(_OutlineColor.rgb * luminance, 0);
			#endif
			}
            ENDCG
        }
    }

    // for battle
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry+401" }

        LOD 100

        Pass
        {
        	NAME "FORWARD"

            Tags { "LightMode" = "ForwardBase" }

            Cull off ZTest LEqual Blend off ZWrite on

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
            #pragma shader_feature _ USE_DECAL

            #pragma multi_compile_fwdbase            
            #pragma multi_compile _ USE_LOCALLIGHT

            #pragma vertex   NPRToonCharacterStandardVS
            #pragma fragment NPRToonCharacterStandardPS
            #include "NPRToonStandard.cginc"
            ENDCG
        }
    }

    FallBack "Diffuse"

    CustomEditor "ToonMaterialEditor"
}