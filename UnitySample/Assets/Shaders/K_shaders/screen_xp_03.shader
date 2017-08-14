// Shader created with Shader Forge Beta 0.36 
// Shader Forge (c) Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:0.36;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:False,lprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:1,bsrc:3,bdst:7,culm:0,dpts:2,wrdp:False,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:1,x:32748,y:32707|emission-151-OUT,alpha-143-OUT;n:type:ShaderForge.SFN_Tex2d,id:2,x:33941,y:32612,ptlb:MainTex,ptin:_MainTex,tex:46440c258bd06914c99bfdb8f5a7589b,ntxv:0,isnm:False;n:type:ShaderForge.SFN_ValueProperty,id:3,x:34383,y:32872,ptlb:Blink,ptin:_Blink,glob:False,v1:0.75;n:type:ShaderForge.SFN_Multiply,id:4,x:33751,y:32774|A-5-OUT,B-3-OUT;n:type:ShaderForge.SFN_Vector1,id:5,x:34042,y:32872,v1:2;n:type:ShaderForge.SFN_Subtract,id:6,x:33395,y:32791|A-4-OUT,B-7-OUT;n:type:ShaderForge.SFN_Vector1,id:7,x:33643,y:33044,v1:1;n:type:ShaderForge.SFN_Clamp01,id:8,x:33199,y:32842|IN-6-OUT;n:type:ShaderForge.SFN_Subtract,id:11,x:33721,y:33180|A-3-OUT,B-12-OUT;n:type:ShaderForge.SFN_Vector1,id:12,x:33928,y:33224,v1:0.5;n:type:ShaderForge.SFN_Abs,id:13,x:33498,y:33218|IN-11-OUT;n:type:ShaderForge.SFN_Multiply,id:14,x:33296,y:33126|A-13-OUT,B-16-OUT;n:type:ShaderForge.SFN_Vector1,id:16,x:33421,y:33390,v1:4;n:type:ShaderForge.SFN_Multiply,id:18,x:33369,y:32581|A-2-RGB,B-111-OUT;n:type:ShaderForge.SFN_Add,id:19,x:33092,y:32623|A-18-OUT,B-8-OUT;n:type:ShaderForge.SFN_If,id:111,x:33826,y:33020|A-3-OUT,B-113-OUT,GT-114-OUT,EQ-114-OUT,LT-115-OUT;n:type:ShaderForge.SFN_Vector1,id:113,x:34250,y:33017,v1:0.5;n:type:ShaderForge.SFN_Vector1,id:114,x:34062,y:33076,v1:1;n:type:ShaderForge.SFN_Vector1,id:115,x:34085,y:33167,v1:0;n:type:ShaderForge.SFN_Multiply,id:123,x:33060,y:33032|A-2-R,B-14-OUT;n:type:ShaderForge.SFN_Clamp01,id:143,x:32914,y:33261|IN-123-OUT;n:type:ShaderForge.SFN_Multiply,id:151,x:33000,y:32476|A-152-RGB,B-19-OUT;n:type:ShaderForge.SFN_Color,id:152,x:33233,y:32394,ptlb:MainColor,ptin:_MainColor,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;proporder:3-2-152;pass:END;sub:END;*/

Shader "Shader Forge/screen_xp_03" {
    Properties {
        _Blink ("Blink", Float ) = 0.75
        _MainTex ("MainTex", 2D) = "white" {}
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
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
            ztest Off
            cull off
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float _Blink;
            uniform float4 _MainColor;
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
                o.pos = float4( v.vertex.xy, 0.0, 1.0 );
                o.pos = sign( o.pos );
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float2 node_172 = i.uv0;
                float4 node_2 = tex2D(_MainTex,TRANSFORM_TEX(node_172.rg, _MainTex));
                float node_111_if_leA = step(_Blink,0.5);
                float node_111_if_leB = step(0.5,_Blink);
                float node_114 = 1.0;
                float3 emissive = (_MainColor.rgb*((node_2.rgb*lerp((node_111_if_leA*0.0)+(node_111_if_leB*node_114),node_114,node_111_if_leA*node_111_if_leB))+saturate(((2.0*_Blink)-1.0))));
                float3 finalColor = emissive;
/// Final Color:
                return fixed4(finalColor,saturate((node_2.r*(abs((_Blink-0.5))*4.0))));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
