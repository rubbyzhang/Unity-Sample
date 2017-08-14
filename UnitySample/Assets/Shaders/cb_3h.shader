// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.35 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.35;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:4013,x:33649,y:32960,varname:node_4013,prsc:2|emission-3817-OUT,alpha-7098-OUT;n:type:ShaderForge.SFN_Tex2d,id:7520,x:32135,y:32818,ptovrint:False,ptlb:node_7520,ptin:_node_7520,varname:node_7520,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:c5cb705d7dc38d44e803f66fa14d3412,ntxv:0,isnm:False|UVIN-9683-UVOUT;n:type:ShaderForge.SFN_Panner,id:9683,x:31956,y:32818,varname:node_9683,prsc:2,spu:0,spv:0|UVIN-8353-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:8353,x:31775,y:32818,varname:node_8353,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:7621,x:32797,y:32889,varname:node_7621,prsc:2|A-9540-OUT,B-7725-RGB;n:type:ShaderForge.SFN_Color,id:7725,x:32536,y:33048,ptovrint:False,ptlb:node_7725,ptin:_node_7725,varname:node_7725,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.8970588,c2:0.1670386,c3:0,c4:1;n:type:ShaderForge.SFN_Multiply,id:3817,x:32991,y:32935,varname:node_3817,prsc:2|A-7621-OUT,B-5028-OUT;n:type:ShaderForge.SFN_Vector1,id:6857,x:32145,y:33036,varname:node_6857,prsc:2,v1:3;n:type:ShaderForge.SFN_Power,id:5534,x:32352,y:32879,varname:node_5534,prsc:2|VAL-7520-R,EXP-6857-OUT;n:type:ShaderForge.SFN_Tex2d,id:401,x:32123,y:33154,ptovrint:False,ptlb:node_401,ptin:_node_401,varname:node_401,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:5acecd7d1a145db40993079f61b7be90,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:9540,x:32580,y:32879,varname:node_9540,prsc:2|A-5534-OUT,B-289-OUT;n:type:ShaderForge.SFN_Power,id:289,x:32355,y:33186,varname:node_289,prsc:2|VAL-401-R,EXP-1544-OUT;n:type:ShaderForge.SFN_Vector1,id:1544,x:32095,y:33340,varname:node_1544,prsc:2,v1:1;n:type:ShaderForge.SFN_ValueProperty,id:5028,x:32768,y:33048,ptovrint:False,ptlb:node_5028,ptin:_node_5028,varname:node_5028,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_VertexColor,id:8386,x:31989,y:33417,varname:node_8386,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4993,x:33339,y:32996,varname:node_4993,prsc:2|A-3817-OUT,B-4702-OUT;n:type:ShaderForge.SFN_Tex2d,id:4198,x:31989,y:33566,ptovrint:False,ptlb:node_4198,ptin:_node_4198,varname:node_4198,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:b87bd26a9e2c9d74699eb3d85259c723,ntxv:0,isnm:False;n:type:ShaderForge.SFN_If,id:4702,x:32286,y:33555,varname:node_4702,prsc:2|A-8386-A,B-4198-R,GT-1336-OUT,EQ-3191-OUT,LT-3191-OUT;n:type:ShaderForge.SFN_Vector1,id:1336,x:32026,y:33750,varname:node_1336,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:3191,x:32009,y:33824,varname:node_3191,prsc:2,v1:0;n:type:ShaderForge.SFN_Multiply,id:7098,x:32655,y:33303,varname:node_7098,prsc:2|A-8386-A,B-5534-OUT;proporder:7520-7725-401-5028-4198;pass:END;sub:END;*/

Shader "Shader Forge/3h" {
    Properties {
        _node_7520 ("node_7520", 2D) = "white" {}
        _node_7725 ("node_7725", Color) = (0.8970588,0.1670386,0,1)
        _node_401 ("node_401", 2D) = "white" {}
        _node_5028 ("node_5028", Float ) = 1
        _node_4198 ("node_4198", 2D) = "white" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
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
            uniform sampler2D _node_7520; uniform float4 _node_7520_ST;
            uniform float4 _node_7725;
            uniform sampler2D _node_401; uniform float4 _node_401_ST;
            uniform float _node_5028;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 node_4614 = _Time + _TimeEditor;
                float2 node_9683 = (i.uv0+node_4614.g*float2(0,0));
                float4 _node_7520_var = tex2D(_node_7520,TRANSFORM_TEX(node_9683, _node_7520));
                float node_5534 = pow(_node_7520_var.r,3.0);
                float4 _node_401_var = tex2D(_node_401,TRANSFORM_TEX(i.uv0, _node_401));
                float3 node_3817 = (((node_5534*pow(_node_401_var.r,1.0))*_node_7725.rgb)*_node_5028);
                float3 emissive = node_3817;
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,(i.vertexColor.a*node_5534));
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
