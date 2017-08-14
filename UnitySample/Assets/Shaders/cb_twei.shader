// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.35 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.35;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:4013,x:34280,y:33050,varname:node_4013,prsc:2|emission-2870-OUT;n:type:ShaderForge.SFN_Panner,id:2950,x:32185,y:32818,varname:node_2950,prsc:2,spu:-0.7,spv:0|UVIN-1139-OUT;n:type:ShaderForge.SFN_TexCoord,id:4482,x:31692,y:32795,varname:node_4482,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:9466,x:32505,y:32624,ptovrint:False,ptlb:node_9466,ptin:_node_9466,varname:node_9466,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:87c83475bb9e54c4a9c5ac3e5add3e26,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:1139,x:31918,y:32848,varname:node_1139,prsc:2|A-4482-UVOUT,B-3840-OUT;n:type:ShaderForge.SFN_Vector2,id:3840,x:31711,y:32976,varname:node_3840,prsc:2,v1:1,v2:1;n:type:ShaderForge.SFN_Tex2d,id:1090,x:32365,y:33148,ptovrint:False,ptlb:node_1090,ptin:_node_1090,varname:node_1090,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:07eb2cfdf055b2444abb2f5be8e6ef3e,ntxv:0,isnm:False|UVIN-2950-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:5074,x:32428,y:33387,ptovrint:False,ptlb:node_5074,ptin:_node_5074,varname:node_5074,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:e4c98e8f7b029e54aa586e3e27cc2c3c,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:8668,x:32918,y:33194,varname:node_8668,prsc:2|A-1090-B,B-8088-OUT;n:type:ShaderForge.SFN_Multiply,id:4785,x:33211,y:32935,varname:node_4785,prsc:2|A-7533-OUT,B-9470-OUT;n:type:ShaderForge.SFN_Multiply,id:1301,x:32784,y:32840,varname:node_1301,prsc:2|A-9466-RGB,B-7509-RGB;n:type:ShaderForge.SFN_Multiply,id:9470,x:32965,y:32840,varname:node_9470,prsc:2|A-1301-OUT,B-760-OUT;n:type:ShaderForge.SFN_ValueProperty,id:760,x:32784,y:32999,ptovrint:False,ptlb:node_760,ptin:_node_760,varname:node_760,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Tex2d,id:9458,x:33459,y:33835,ptovrint:False,ptlb:node_9458,ptin:_node_9458,varname:node_9458,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:5acecd7d1a145db40993079f61b7be90,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3666,x:33853,y:33551,varname:node_3666,prsc:2|A-5617-OUT,B-7088-OUT;n:type:ShaderForge.SFN_Color,id:7509,x:32488,y:32830,ptovrint:False,ptlb:node_7509,ptin:_node_7509,varname:node_7509,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Slider,id:7533,x:32532,y:33089,ptovrint:False,ptlb:node_7533,ptin:_node_7533,varname:node_7533,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Tex2d,id:7335,x:32033,y:33717,ptovrint:False,ptlb:node_7335,ptin:_node_7335,varname:node_7335,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:0b612b2fcbeb36041a1a29abd1e4b11b,ntxv:0,isnm:False|UVIN-4084-UVOUT;n:type:ShaderForge.SFN_Multiply,id:8088,x:32674,y:33449,varname:node_8088,prsc:2|A-5074-R,B-5131-OUT;n:type:ShaderForge.SFN_Vector1,id:5131,x:32428,y:33581,varname:node_5131,prsc:2,v1:2;n:type:ShaderForge.SFN_Panner,id:4084,x:31873,y:33717,varname:node_4084,prsc:2,spu:-2,spv:0|UVIN-5763-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:5763,x:31710,y:33717,varname:node_5763,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_If,id:4794,x:32306,y:33715,varname:node_4794,prsc:2|A-6632-OUT,B-7335-R,GT-6823-OUT,EQ-1583-OUT,LT-1583-OUT;n:type:ShaderForge.SFN_Slider,id:6632,x:31873,y:33621,ptovrint:False,ptlb:node_6632,ptin:_node_6632,varname:node_6632,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3706222,max:1;n:type:ShaderForge.SFN_Vector1,id:6823,x:32046,y:33881,varname:node_6823,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:1583,x:32051,y:33933,varname:node_1583,prsc:2,v1:0;n:type:ShaderForge.SFN_Multiply,id:1144,x:33416,y:33335,varname:node_1144,prsc:2|A-1090-G,B-4794-OUT;n:type:ShaderForge.SFN_Multiply,id:6439,x:33837,y:33165,varname:node_6439,prsc:2|A-3811-OUT,B-3666-OUT;n:type:ShaderForge.SFN_Tex2d,id:3641,x:33401,y:33509,ptovrint:False,ptlb:node_3641,ptin:_node_3641,varname:node_3641,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:0fca55033ca82714c8fd490b6d7a3e7c,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Vector1,id:260,x:33425,y:33707,varname:node_260,prsc:2,v1:2;n:type:ShaderForge.SFN_Power,id:5617,x:33653,y:33539,varname:node_5617,prsc:2|VAL-3641-R,EXP-260-OUT;n:type:ShaderForge.SFN_Multiply,id:2870,x:34032,y:33391,varname:node_2870,prsc:2|A-6439-OUT,B-8088-OUT;n:type:ShaderForge.SFN_Multiply,id:3811,x:33618,y:33000,varname:node_3811,prsc:2|A-7509-RGB,B-1090-G;n:type:ShaderForge.SFN_Power,id:7088,x:33687,y:33835,varname:node_7088,prsc:2|VAL-9458-R,EXP-360-OUT;n:type:ShaderForge.SFN_Vector1,id:360,x:33470,y:34005,varname:node_360,prsc:2,v1:2;proporder:9466-1090-5074-760-9458-7509-7533-7335-6632-3641;pass:END;sub:END;*/

Shader "Shader Forge/twei" {
    Properties {
        _node_9466 ("node_9466", 2D) = "white" {}
        _node_1090 ("node_1090", 2D) = "white" {}
        _node_5074 ("node_5074", 2D) = "white" {}
        _node_760 ("node_760", Float ) = 2
        _node_9458 ("node_9458", 2D) = "white" {}
        _node_7509 ("node_7509", Color) = (0.5,0.5,0.5,1)
        _node_7533 ("node_7533", Range(0, 1)) = 1
        _node_7335 ("node_7335", 2D) = "white" {}
        _node_6632 ("node_6632", Range(0, 1)) = 0.3706222
        _node_3641 ("node_3641", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _node_1090; uniform float4 _node_1090_ST;
            uniform sampler2D _node_5074; uniform float4 _node_5074_ST;
            uniform sampler2D _node_9458; uniform float4 _node_9458_ST;
            uniform float4 _node_7509;
            uniform sampler2D _node_3641; uniform float4 _node_3641_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 node_2663 = _Time + _TimeEditor;
                float2 node_2950 = ((i.uv0*float2(1,1))+node_2663.g*float2(-0.7,0));
                float4 _node_1090_var = tex2D(_node_1090,TRANSFORM_TEX(node_2950, _node_1090));
                float4 _node_3641_var = tex2D(_node_3641,TRANSFORM_TEX(i.uv0, _node_3641));
                float4 _node_9458_var = tex2D(_node_9458,TRANSFORM_TEX(i.uv0, _node_9458));
                float4 _node_5074_var = tex2D(_node_5074,TRANSFORM_TEX(i.uv0, _node_5074));
                float node_8088 = (_node_5074_var.r*2.0);
                float3 emissive = (((_node_7509.rgb*_node_1090_var.g)*(pow(_node_3641_var.r,2.0)*pow(_node_9458_var.r,2.0)))*node_8088);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos(v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
