// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge Beta 0.36 
// Shader Forge (c) Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:0.36;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:0,uamb:True,mssp:True,lmpd:False,lprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:1,bsrc:3,bdst:7,culm:0,dpts:2,wrdp:False,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:1,x:32719,y:32712|emission-643-OUT,alpha-655-OUT;n:type:ShaderForge.SFN_Tex2d,id:2,x:33657,y:32889,ptlb:Mask,ptin:_Mask,tex:51ab1aef2c370a343a8bafe6b3f63726,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:3,x:33626,y:32660,ptlb:MainTex,ptin:_MainTex,tex:98667e6062bb0d0439aa1288f430215f,ntxv:0,isnm:False|UVIN-126-OUT;n:type:ShaderForge.SFN_Tex2d,id:4,x:33616,y:32413,ptlb:Detail,ptin:_Detail,tex:98667e6062bb0d0439aa1288f430215f,ntxv:2,isnm:False|UVIN-81-OUT;n:type:ShaderForge.SFN_Multiply,id:41,x:33296,y:32459|A-4-RGB,B-3-RGB;n:type:ShaderForge.SFN_Rotator,id:46,x:34263,y:32410|UVIN-130-UVOUT,SPD-618-OUT;n:type:ShaderForge.SFN_Multiply,id:55,x:34059,y:32503|A-46-UVOUT,B-56-OUT;n:type:ShaderForge.SFN_Vector1,id:56,x:34281,y:32731,v1:0.7;n:type:ShaderForge.SFN_Add,id:81,x:33838,y:32329|A-55-OUT,B-82-OUT;n:type:ShaderForge.SFN_Vector1,id:82,x:34072,y:32731,v1:0.15;n:type:ShaderForge.SFN_Multiply,id:122,x:34014,y:32832|A-148-UVOUT,B-124-OUT;n:type:ShaderForge.SFN_Vector1,id:124,x:34254,y:33108,v1:0.7;n:type:ShaderForge.SFN_Add,id:126,x:33819,y:32810|A-122-OUT,B-128-OUT;n:type:ShaderForge.SFN_Vector1,id:128,x:34045,y:33108,v1:0.15;n:type:ShaderForge.SFN_TexCoord,id:130,x:34497,y:32369,uv:0;n:type:ShaderForge.SFN_Rotator,id:148,x:34218,y:32861|UVIN-152-UVOUT,SPD-628-OUT;n:type:ShaderForge.SFN_TexCoord,id:152,x:34452,y:32820,uv:0;n:type:ShaderForge.SFN_Add,id:403,x:33239,y:32793|A-758-OUT,B-758-OUT;n:type:ShaderForge.SFN_ValueProperty,id:618,x:34587,y:32693,ptlb:Speed_d,ptin:_Speed_d,glob:False,v1:1;n:type:ShaderForge.SFN_ValueProperty,id:628,x:34647,y:33055,ptlb:Speed_m,ptin:_Speed_m,glob:False,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:643,x:33044,y:32627|A-41-OUT,B-644-RGB;n:type:ShaderForge.SFN_Color,id:644,x:33803,y:33206,ptlb:MainColor,ptin:_MainColor,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:655,x:33015,y:33040|A-791-OUT,B-644-A;n:type:ShaderForge.SFN_Multiply,id:758,x:33412,y:32767|A-2-G,B-2-B;n:type:ShaderForge.SFN_Clamp01,id:791,x:33201,y:32971|IN-870-OUT;n:type:ShaderForge.SFN_ComponentMask,id:809,x:33296,y:32640,cc1:0,cc2:-1,cc3:-1,cc4:-1|IN-41-OUT;n:type:ShaderForge.SFN_Multiply,id:810,x:33446,y:33004|A-809-OUT,B-403-OUT;n:type:ShaderForge.SFN_Sin,id:835,x:33508,y:33377|IN-895-OUT;n:type:ShaderForge.SFN_Time,id:840,x:34223,y:33276;n:type:ShaderForge.SFN_Frac,id:842,x:33933,y:33381|IN-946-OUT;n:type:ShaderForge.SFN_Multiply,id:870,x:33223,y:33209|A-810-OUT,B-936-OUT;n:type:ShaderForge.SFN_Multiply,id:895,x:33727,y:33447|A-842-OUT,B-896-OUT;n:type:ShaderForge.SFN_Vector1,id:896,x:33969,y:33605,v1:3.14;n:type:ShaderForge.SFN_Add,id:936,x:33210,y:33405|A-835-OUT,B-937-OUT;n:type:ShaderForge.SFN_Vector1,id:937,x:33385,y:33562,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:946,x:34152,y:33452|A-840-T,B-947-OUT;n:type:ShaderForge.SFN_ValueProperty,id:947,x:34499,y:33543,ptlb:Speed_a,ptin:_Speed_a,glob:False,v1:0.5;proporder:2-3-4-618-628-644-947;pass:END;sub:END;*/

Shader "Shader Forge/screen_xp_02" {
    Properties {
        _Mask ("Mask", 2D) = "white" {}
        _MainTex ("MainTex", 2D) = "white" {}
        _Detail ("Detail", 2D) = "black" {}
        _Speed_d ("Speed_d", Float ) = 1
        _Speed_m ("Speed_m", Float ) = 0.5
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _Speed_a ("Speed_a", Float ) = 0.5
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _Detail; uniform float4 _Detail_ST;
            uniform float _Speed_d;
            uniform float _Speed_m;
            uniform float4 _MainColor;
            uniform float _Speed_a;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 node_997 = _Time + _TimeEditor;
                float node_46_ang = node_997.g;
                float node_46_spd = _Speed_d;
                float node_46_cos = cos(node_46_spd*node_46_ang);
                float node_46_sin = sin(node_46_spd*node_46_ang);
                float2 node_46_piv = float2(0.5,0.5);
                float2 node_46 = (mul(i.uv0.rg-node_46_piv,float2x2( node_46_cos, -node_46_sin, node_46_sin, node_46_cos))+node_46_piv);
                float2 node_81 = ((node_46*0.7)+0.15);
                float node_148_ang = node_997.g;
                float node_148_spd = _Speed_m;
                float node_148_cos = cos(node_148_spd*node_148_ang);
                float node_148_sin = sin(node_148_spd*node_148_ang);
                float2 node_148_piv = float2(0.5,0.5);
                float2 node_148 = (mul(i.uv0.rg-node_148_piv,float2x2( node_148_cos, -node_148_sin, node_148_sin, node_148_cos))+node_148_piv);
                float2 node_126 = ((node_148*0.7)+0.15);
                float3 node_41 = (tex2D(_Detail,TRANSFORM_TEX(node_81, _Detail)).rgb*tex2D(_MainTex,TRANSFORM_TEX(node_126, _MainTex)).rgb);
                float3 emissive = (node_41*_MainColor.rgb);
                float3 finalColor = emissive;
                float2 node_996 = i.uv0;
                float4 node_2 = tex2D(_Mask,TRANSFORM_TEX(node_996.rg, _Mask));
                float node_758 = (node_2.g*node_2.b);
                float4 node_840 = _Time + _TimeEditor;
                float node_655 = (saturate(((node_41.r*(node_758+node_758))*(sin((frac((node_840.g*_Speed_a))*3.14))+0.5)))*_MainColor.a);
/// Final Color:
                return fixed4(finalColor,node_655);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
