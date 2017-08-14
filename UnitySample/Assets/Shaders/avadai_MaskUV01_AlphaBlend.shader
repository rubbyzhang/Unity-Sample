// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.25 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.25;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33591,y:32730,varname:node_3138,prsc:2|emission-515-OUT,alpha-159-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32285,y:32584,ptovrint:False,ptlb:Color,ptin:_Color,varname:_Color,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.6397059,c2:0.6397059,c3:0.6397059,c4:1;n:type:ShaderForge.SFN_Tex2d,id:6576,x:32306,y:33607,ptovrint:False,ptlb:Texture1,ptin:_Texture1,varname:_node_6576,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:59b16ecd58fc02445a88231894ea915a,ntxv:0,isnm:False|UVIN-8136-UVOUT;n:type:ShaderForge.SFN_ValueProperty,id:7992,x:31568,y:33697,ptovrint:False,ptlb:U Speed1,ptin:_USpeed1,varname:_node_m,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:3210,x:31762,y:33589,varname:node_3210,prsc:2|A-8688-T,B-7992-OUT;n:type:ShaderForge.SFN_Multiply,id:754,x:32511,y:33771,varname:node_754,prsc:2|A-6576-A,B-988-A;n:type:ShaderForge.SFN_Multiply,id:9393,x:32703,y:32663,varname:node_9393,prsc:2|A-1879-OUT,B-2425-RGB;n:type:ShaderForge.SFN_VertexColor,id:2425,x:32494,y:32760,varname:node_2425,prsc:2;n:type:ShaderForge.SFN_Multiply,id:515,x:33147,y:32777,varname:node_515,prsc:2|A-9393-OUT,B-2434-OUT;n:type:ShaderForge.SFN_TexCoord,id:4853,x:31599,y:33350,varname:node_4853,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:2365,x:31926,y:33480,varname:node_2365,prsc:2,spu:1,spv:0|UVIN-4853-UVOUT,DIST-3210-OUT;n:type:ShaderForge.SFN_Time,id:8688,x:31568,y:33520,varname:node_8688,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:5550,x:31568,y:33791,ptovrint:False,ptlb:V Speed1,ptin:_VSpeed1,varname:_node_m_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:5509,x:31762,y:33733,varname:node_5509,prsc:2|A-8688-T,B-5550-OUT;n:type:ShaderForge.SFN_Tex2d,id:988,x:32297,y:34040,ptovrint:False,ptlb:Texture2,ptin:_Texture2,varname:_Texture2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:75b8a9054cf709e478d2de1cea0c92c0,ntxv:0,isnm:False|UVIN-2914-UVOUT;n:type:ShaderForge.SFN_Time,id:4466,x:31559,y:34164,varname:node_4466,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:7938,x:31559,y:34347,ptovrint:False,ptlb:U Speed2,ptin:_USpeed2,varname:_USpeed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:9098,x:31753,y:34240,varname:node_9098,prsc:2|A-4466-T,B-7938-OUT;n:type:ShaderForge.SFN_TexCoord,id:4889,x:31559,y:34004,varname:node_4889,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:3140,x:31906,y:34145,varname:node_3140,prsc:2,spu:1,spv:0|UVIN-4889-UVOUT,DIST-9098-OUT;n:type:ShaderForge.SFN_ValueProperty,id:25,x:31559,y:34475,ptovrint:False,ptlb:V Speed2,ptin:_VSpeed2,varname:_VSpeed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:6807,x:31753,y:34397,varname:node_6807,prsc:2|A-4466-T,B-25-OUT;n:type:ShaderForge.SFN_Panner,id:2914,x:32122,y:34175,varname:node_2914,prsc:2,spu:0,spv:1|UVIN-3140-UVOUT,DIST-6807-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8352,x:32050,y:32761,ptovrint:False,ptlb:Intensity,ptin:_Intensity,varname:node_8352,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Fresnel,id:3466,x:32542,y:33123,varname:node_3466,prsc:2|EXP-7242-OUT;n:type:ShaderForge.SFN_Blend,id:3456,x:32946,y:33192,varname:node_3456,prsc:2,blmd:13,clmp:True|SRC-8966-OUT,DST-754-OUT;n:type:ShaderForge.SFN_OneMinus,id:8966,x:32699,y:33123,varname:node_8966,prsc:2|IN-3466-OUT;n:type:ShaderForge.SFN_Slider,id:6350,x:31983,y:33162,ptovrint:False,ptlb:MeshEdge,ptin:_MeshEdge,varname:node_6350,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:5;n:type:ShaderForge.SFN_Multiply,id:1879,x:32494,y:32584,varname:node_1879,prsc:2|A-7241-RGB,B-8352-OUT;n:type:ShaderForge.SFN_Multiply,id:946,x:32766,y:32954,varname:node_946,prsc:2|A-6576-RGB,B-988-RGB;n:type:ShaderForge.SFN_Blend,id:2434,x:32989,y:32915,varname:node_2434,prsc:2,blmd:1,clmp:True|SRC-8966-OUT,DST-946-OUT;n:type:ShaderForge.SFN_Power,id:8447,x:33133,y:33210,varname:node_8447,prsc:2|VAL-3456-OUT,EXP-2094-OUT;n:type:ShaderForge.SFN_Multiply,id:159,x:33327,y:33039,varname:node_159,prsc:2|A-7241-A,B-8447-OUT;n:type:ShaderForge.SFN_Multiply,id:7242,x:32352,y:33142,varname:node_7242,prsc:2|A-2425-A,B-6350-OUT;n:type:ShaderForge.SFN_Slider,id:2094,x:32765,y:33480,ptovrint:False,ptlb:TexEdge,ptin:_TexEdge,varname:_MeshEdge_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:1,cur:1,max:10;n:type:ShaderForge.SFN_Panner,id:8136,x:32077,y:33574,varname:node_8136,prsc:2,spu:0,spv:1|UVIN-2365-UVOUT,DIST-5509-OUT;proporder:7241-8352-6576-7992-5550-988-7938-25-6350-2094;pass:END;sub:END;*/

Shader "Effects/avadai_MaskUV01_AlphaBlend" {
    Properties {
        _Color ("Color", Color) = (0.6397059,0.6397059,0.6397059,1)
        _Intensity ("Intensity", Float ) = 1
        _Texture1 ("Texture1", 2D) = "white" {}
        _USpeed1 ("U Speed1", Float ) = 0
        _VSpeed1 ("V Speed1", Float ) = 0
        _Texture2 ("Texture2", 2D) = "white" {}
        _USpeed2 ("U Speed2", Float ) = 0
        _VSpeed2 ("V Speed2", Float ) = 0
        _MeshEdge ("MeshEdge", Range(0, 5)) = 1
        _TexEdge ("TexEdge", Range(1, 10)) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
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
            Blend SrcAlpha OneMinusSrcAlpha
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
                float4 node_8688 = _Time + _TimeEditor;
                float2 node_8136 = ((i.uv0+(node_8688.g*_USpeed1)*float2(1,0))+(node_8688.g*_VSpeed1)*float2(0,1));
                float4 _Texture1_var = tex2D(_Texture1,TRANSFORM_TEX(node_8136, _Texture1));
                float4 node_4466 = _Time + _TimeEditor;
                float2 node_2914 = ((i.uv0+(node_4466.g*_USpeed2)*float2(1,0))+(node_4466.g*_VSpeed2)*float2(0,1));
                float4 _Texture2_var = tex2D(_Texture2,TRANSFORM_TEX(node_2914, _Texture2));
                float3 emissive = (((_Color.rgb*_Intensity)*i.vertexColor.rgb)*saturate((node_8966*(_Texture1_var.rgb*_Texture2_var.rgb))));
                float3 finalColor = emissive;
                return fixed4(finalColor,(_Color.a*pow(saturate(( node_8966 > 0.5 ? ((_Texture1_var.a*_Texture2_var.a)/((1.0-node_8966)*2.0)) : (1.0-(((1.0-(_Texture1_var.a*_Texture2_var.a))*0.5)/node_8966)))),_TexEdge)));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
