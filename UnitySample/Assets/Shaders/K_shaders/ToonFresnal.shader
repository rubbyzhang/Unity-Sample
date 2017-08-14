// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge Beta 0.17 
// Shader Forge (c) Joachim 'Acegikmo' Holmer
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:0.17;sub:START;pass:START;ps:lgpr:1,nrmq:0,limd:0,blpr:0,bsrc:0,bdst:0,culm:0,dpts:2,wrdp:True,uamb:False,mssp:True,ufog:True,aust:True,igpj:False,qofs:0,lico:0,qpre:1,flbk:,rntp:1,lmpd:False,lprd:True,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,hqsc:True,hqlp:False,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300;n:type:ShaderForge.SFN_Final,id:1,x:32719,y:32712|emission-353-OUT;n:type:ShaderForge.SFN_Cubemap,id:3,x:33613,y:32778,ptlb:node_3,cube:4383f1ea7ac38b04ebdee26d146d1bec,pvfc:0|DIR-306-XYZ;n:type:ShaderForge.SFN_NormalVector,id:176,x:33993,y:32778,pt:False;n:type:ShaderForge.SFN_Multiply,id:290,x:33156,y:32764|A-579-RGB,B-3-RGB;n:type:ShaderForge.SFN_Transform,id:306,x:33799,y:32778,tffrom:0,tfto:3|IN-176-OUT;n:type:ShaderForge.SFN_Fresnel,id:342,x:33439,y:32346|EXP-362-OUT;n:type:ShaderForge.SFN_Add,id:353,x:32954,y:32460|A-404-OUT,B-290-OUT;n:type:ShaderForge.SFN_Vector1,id:362,x:33639,y:32364,v1:3;n:type:ShaderForge.SFN_Multiply,id:404,x:33209,y:32346|A-342-OUT,B-464-OUT;n:type:ShaderForge.SFN_Power,id:427,x:33899,y:32475|VAL-3-RGB,EXP-428-OUT;n:type:ShaderForge.SFN_Vector1,id:428,x:33975,y:32607,v1:5;n:type:ShaderForge.SFN_Vector1,id:463,x:33760,y:32509,v1:4;n:type:ShaderForge.SFN_Multiply,id:464,x:33439,y:32484|A-427-OUT,B-463-OUT;n:type:ShaderForge.SFN_Tex2d,id:579,x:33329,y:32643,ptlb:node_579,tex:15c70de5a996e82489cf26c2452d7562,ntxv:0,isnm:False;proporder:3-579;pass:END;sub:END;*/

Shader "Toon/Fresnal" {
    Properties {
    	_Color ("Main Color", Color) = (1,1,1,1)
        //_GlobalToonLight ("ToonShader Cubemap(RGB)", Cube) = "_Skybox" {}
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_GlowTex ("Glow", 2D) = "black" {}
		_CutOff("CutOff",Range(0,1))=0
		_Additive ("Additive", Float) = 0
		_AdditiveColor ("AdditiveColor", Color) = (1,1,1,1)
    }
    SubShader {
    	Blend srcalpha oneminussrcalpha
        Tags {
            "RenderType"="Opaque"
            "Queue"="Transparent-200"
        }
        Pass {
//            Name "ForwardBase"
//            Tags {
//                "LightMode"="ForwardBase"
//            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            //#pragma multi_compile QUALITY_FIRST PERFORMANCE_FIRST
            #pragma exclude_renderers xbox360 ps3 flash 
            #pragma target 3.0
            uniform fixed4 _Color;
            uniform fixed4 _SceneColor;
            uniform samplerCUBE _GlobalToonLight;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
			uniform sampler2D _GlowTex;
			uniform float _CutOff;
			uniform float _Additive;
			uniform float4 _AdditiveColor;
			
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 uv0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex);
                o.normalDir = mul(float4(v.normal,0), unity_WorldToObject).xyz;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
            	float4 col = tex2D(_MainTex, i.uv0);
            	if(col.a < _CutOff)
					discard;
            
                //float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                //float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float4 toonlight = texCUBE(_GlobalToonLight,mul( UNITY_MATRIX_V, float4(i.normalDir,0) ).xyz.rgb);
                
                toonlight.rgb = toonlight.rgb * toonlight.rgb * 1.5f;
                
                float3 finalColor = (col.rgb*toonlight.rgb);
                
               	//#ifdef QUALITY_FIRST
                //finalColor += (_SceneColor.rgb * pow(1.0-max(0,dot(normalDirection, viewDirection)),3.0)*(pow(toonlight.rgb,5.0)*4.0));
                //#endif
////// Glow:               
                fixed4 glowColor = tex2D(_GlowTex, i.uv0 );
/// Final Color:
                return fixed4(finalColor + glowColor.rgb + _Additive * _AdditiveColor.rgb,_Color.a);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
