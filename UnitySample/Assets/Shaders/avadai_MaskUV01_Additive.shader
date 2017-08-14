// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.25 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.25;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33666,y:32711,varname:node_3138,prsc:2|emission-515-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32186,y:32470,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Tex2d,id:6576,x:32294,y:33667,ptovrint:False,ptlb:Texture1,ptin:_Texture1,varname:_node_6576,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:75b8a9054cf709e478d2de1cea0c92c0,ntxv:0,isnm:False|UVIN-8395-UVOUT;n:type:ShaderForge.SFN_Time,id:8137,x:31568,y:33514,varname:node_8137,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:7992,x:31568,y:33697,ptovrint:False,ptlb:U Speed1,ptin:_USpeed1,varname:_node_m,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:3210,x:31762,y:33590,varname:node_3210,prsc:2|A-8137-T,B-7992-OUT;n:type:ShaderForge.SFN_VertexColor,id:2425,x:32212,y:32909,varname:node_2425,prsc:2;n:type:ShaderForge.SFN_Multiply,id:515,x:33419,y:32794,varname:node_515,prsc:2|A-6040-OUT,B-5497-OUT;n:type:ShaderForge.SFN_TexCoord,id:4853,x:31775,y:33344,varname:node_4853,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:2365,x:31929,y:33501,varname:node_2365,prsc:2,spu:1,spv:0|UVIN-4853-UVOUT,DIST-3210-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5550,x:31568,y:33808,ptovrint:False,ptlb:V Speed1,ptin:_VSpeed1,varname:_node_m_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:5509,x:31809,y:33741,varname:node_5509,prsc:2|A-8137-T,B-5550-OUT;n:type:ShaderForge.SFN_Panner,id:8395,x:32116,y:33551,varname:node_8395,prsc:2,spu:0,spv:1|UVIN-2365-UVOUT,DIST-5509-OUT;n:type:ShaderForge.SFN_Tex2d,id:988,x:32297,y:34040,ptovrint:False,ptlb:Texture2,ptin:_Texture2,varname:_Texture2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:75b8a9054cf709e478d2de1cea0c92c0,ntxv:0,isnm:False|UVIN-2914-UVOUT;n:type:ShaderForge.SFN_Time,id:4466,x:31559,y:34164,varname:node_4466,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:7938,x:31559,y:34347,ptovrint:False,ptlb:U Speed2,ptin:_USpeed2,varname:_USpeed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:9098,x:31753,y:34240,varname:node_9098,prsc:2|A-4466-T,B-7938-OUT;n:type:ShaderForge.SFN_TexCoord,id:4889,x:31765,y:33994,varname:node_4889,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:3140,x:31919,y:34151,varname:node_3140,prsc:2,spu:1,spv:0|UVIN-4889-UVOUT,DIST-9098-OUT;n:type:ShaderForge.SFN_ValueProperty,id:25,x:31559,y:34490,ptovrint:False,ptlb:V Speed2,ptin:_VSpeed2,varname:_VSpeed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:6807,x:31763,y:34384,varname:node_6807,prsc:2|A-4466-T,B-25-OUT;n:type:ShaderForge.SFN_Panner,id:2914,x:32085,y:34192,varname:node_2914,prsc:2,spu:0,spv:1|UVIN-3140-UVOUT,DIST-6807-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8352,x:32025,y:32770,ptovrint:False,ptlb:Intensity,ptin:_Intensity,varname:node_8352,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Fresnel,id:3466,x:32557,y:33112,varname:node_3466,prsc:2|EXP-1723-OUT;n:type:ShaderForge.SFN_Blend,id:3456,x:32944,y:33112,varname:node_3456,prsc:2,blmd:1,clmp:True|SRC-8966-OUT,DST-9700-OUT;n:type:ShaderForge.SFN_OneMinus,id:8966,x:32730,y:33112,varname:node_8966,prsc:2|IN-3466-OUT;n:type:ShaderForge.SFN_Slider,id:6350,x:32055,y:33155,ptovrint:False,ptlb:MeshEdge,ptin:_MeshEdge,varname:node_6350,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:3;n:type:ShaderForge.SFN_Power,id:5497,x:33482,y:33218,varname:node_5497,prsc:2|VAL-6831-OUT,EXP-5928-OUT;n:type:ShaderForge.SFN_Multiply,id:6040,x:32671,y:32648,varname:node_6040,prsc:2|A-7241-RGB,B-639-OUT,C-2425-RGB;n:type:ShaderForge.SFN_Slider,id:5928,x:33119,y:33445,ptovrint:False,ptlb:TexEdge,ptin:_TexEdge,varname:_MeshEdge_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0.5,cur:1,max:3;n:type:ShaderForge.SFN_Multiply,id:1723,x:32391,y:33028,varname:node_1723,prsc:2|A-2425-A,B-6350-OUT;n:type:ShaderForge.SFN_Multiply,id:9700,x:32744,y:33478,varname:node_9700,prsc:2|A-6576-RGB,B-988-RGB;n:type:ShaderForge.SFN_Multiply,id:4187,x:32744,y:33647,varname:node_4187,prsc:2|A-6576-A,B-988-A;n:type:ShaderForge.SFN_Blend,id:6612,x:32963,y:33319,varname:node_6612,prsc:2,blmd:13,clmp:True|SRC-8966-OUT,DST-4187-OUT;n:type:ShaderForge.SFN_Multiply,id:6831,x:33156,y:33213,varname:node_6831,prsc:2|A-3456-OUT,B-6612-OUT;n:type:ShaderForge.SFN_RemapRange,id:639,x:32286,y:32737,varname:node_639,prsc:2,frmn:0,frmx:1,tomn:0,tomx:2|IN-8352-OUT;proporder:7241-8352-6576-7992-5550-988-7938-25-6350-5928;pass:END;sub:END;*/

Shader "Effects/avadai_MaskUV01_Additive" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Intensity ("Intensity", Float ) = 1
        _Texture1 ("Texture1", 2D) = "white" {}
        _USpeed1 ("U Speed1", Float ) = 0
        _VSpeed1 ("V Speed1", Float ) = 0
        _Texture2 ("Texture2", 2D) = "white" {}
        _USpeed2 ("U Speed2", Float ) = 0
        _VSpeed2 ("V Speed2", Float ) = 0
        _MeshEdge ("MeshEdge", Range(0, 3)) = 1
        _TexEdge ("TexEdge", Range(0.5, 3)) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", float) = 0
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
            Blend One One
            ZWrite Off
            Cull [_CullMode]
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform float4 _Color;
            uniform sampler2D _Texture1; uniform float4 _Texture1_ST;
            uniform float _USpeed1;
            uniform float _VSpeed1;
            uniform sampler2D _Texture2; uniform float4 _Texture2_ST;
            uniform float _USpeed2;
            uniform float _VSpeed2;
            uniform float _Intensity;
            uniform float _MeshEdge;
            uniform float _TexEdge;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float node_8966 = (1.0 - pow(1.0-max(0,dot(normalDirection, viewDirection)),(i.vertexColor.a*_MeshEdge)));
                float4 node_8137 = _Time + _TimeEditor;
                float2 node_8395 = ((i.uv0+(node_8137.g*_USpeed1)*float2(1,0))+(node_8137.g*_VSpeed1)*float2(0,1));
                float4 _Texture1_var = tex2D(_Texture1,TRANSFORM_TEX(node_8395, _Texture1));
                float4 node_4466 = _Time + _TimeEditor;
                float2 node_2914 = ((i.uv0+(node_4466.g*_USpeed2)*float2(1,0))+(node_4466.g*_VSpeed2)*float2(0,1));
                float4 _Texture2_var = tex2D(_Texture2,TRANSFORM_TEX(node_2914, _Texture2));
                float3 emissive = ((_Color.rgb*(_Intensity*2.0+0.0)*i.vertexColor.rgb)*pow((saturate((node_8966*(_Texture1_var.rgb*_Texture2_var.rgb)))*saturate(( node_8966 > 0.5 ? ((_Texture1_var.a*_Texture2_var.a)/((1.0-node_8966)*2.0)) : (1.0-(((1.0-(_Texture1_var.a*_Texture2_var.a))*0.5)/node_8966))))),_TexEdge));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
