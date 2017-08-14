// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge Beta 0.25 
// Shader Forge (c) Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:0.25;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:0,uamb:True,mssp:True,lmpd:False,lprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,hqsc:True,hqlp:False,blpr:0,bsrc:0,bdst:1,culm:0,dpts:2,wrdp:True,ufog:False,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.4039216,fgcg:0.827451,fgcb:1,fgca:1,fgde:0.01,fgrn:8,fgrf:60,ofsf:0,ofsu:0;n:type:ShaderForge.SFN_Final,id:1,x:32719,y:32712|emission-42-OUT,clip-2-A;n:type:ShaderForge.SFN_Tex2d,id:2,x:33944,y:32664,ptlb:Main_Tex,tex:78edd960ca6c35a438507eadb159f4a1,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:41,x:33748,y:33072,ptlb:Q_Tex,tex:e490ca7614e20614eae5ec766e37405c,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:42,x:32967,y:32557|A-105-OUT,B-143-OUT;n:type:ShaderForge.SFN_Multiply,id:50,x:33518,y:32941|A-2-RGB,B-41-RGB;n:type:ShaderForge.SFN_Multiply,id:69,x:33215,y:32838|A-50-OUT,B-207-OUT;n:type:ShaderForge.SFN_ValueProperty,id:90,x:33660,y:32803,ptlb:Q_str,v1:2;n:type:ShaderForge.SFN_Color,id:97,x:33811,y:32246,ptlb:Main_Color,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:105,x:33184,y:32407|A-230-OUT,B-2-RGB;n:type:ShaderForge.SFN_Multiply,id:143,x:33184,y:32590|A-144-RGB,B-69-OUT;n:type:ShaderForge.SFN_Color,id:144,x:33852,y:32522,ptlb:Q_Color,c1:0.6617647,c2:0.6617647,c3:0.6617647,c4:1;n:type:ShaderForge.SFN_Multiply,id:207,x:33449,y:32719|A-144-A,B-90-OUT;n:type:ShaderForge.SFN_Multiply,id:215,x:33550,y:32375|A-97-A,B-217-OUT;n:type:ShaderForge.SFN_ValueProperty,id:217,x:33771,y:32434,ptlb:M_str,v1:1;n:type:ShaderForge.SFN_Multiply,id:230,x:33349,y:32305|A-97-RGB,B-215-OUT;proporder:2-41-90-97-144-217;pass:END;sub:END;*/

Shader "Shader Forge/ShiftColor" {
    Properties {
        _MainTex ("Main_Tex", 2D) = "white" {}
        _QTex ("Q_Tex", 2D) = "white" {}
        _Qstr ("Q_str", Float ) = 2
        _MainColor ("Main_Color", Color) = (1,1,1,1)
        _QColor ("Q_Color", Color) = (0.6617647,0.6617647,0.6617647,1)
        _Mstr ("M_str", Float ) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="Transparent"
            "RenderType"="TransparentCutout"
        }
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers xbox360 ps3 flash 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _QTex; uniform float4 _QTex_ST;
            uniform float _Qstr;
            uniform float4 _MainColor;
            uniform float4 _QColor;
            uniform float _Mstr;
            struct VertexInput {
                float4 vertex : POSITION;
                float4 uv0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                float2 node_257 = i.uv0;
                float4 node_2 = tex2D(_MainTex,TRANSFORM_TEX(node_257.rg, _MainTex));
                clip(node_2.a - 0.5);
////// Lighting:
////// Emissive:
                float4 node_97 = _MainColor;
                float4 node_144 = _QColor;
                float3 emissive = (((node_97.rgb*(node_97.a*_Mstr))*node_2.rgb)+(node_144.rgb*((node_2.rgb*tex2D(_QTex,TRANSFORM_TEX(node_257.rg, _QTex)).rgb)*(node_144.a*_Qstr))));
                float3 finalColor = emissive;
/// Final Color:
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCollector"
            Tags {
                "LightMode"="ShadowCollector"
            }
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCOLLECTOR
            #define SHADOW_COLLECTOR_PASS
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcollector
            #pragma exclude_renderers xbox360 ps3 flash 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float4 uv0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_COLLECTOR;
                float4 uv0 : TEXCOORD5;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW_COLLECTOR(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                float2 node_258 = i.uv0;
                float4 node_2 = tex2D(_MainTex,TRANSFORM_TEX(node_258.rg, _MainTex));
                clip(node_2.a - 0.5);
                SHADOW_COLLECTOR_FRAGMENT(i)
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Cull Off
            Offset 1, 1
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma exclude_renderers xbox360 ps3 flash 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float4 uv0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float4 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                float2 node_259 = i.uv0;
                float4 node_2 = tex2D(_MainTex,TRANSFORM_TEX(node_259.rg, _MainTex));
                clip(node_2.a - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
