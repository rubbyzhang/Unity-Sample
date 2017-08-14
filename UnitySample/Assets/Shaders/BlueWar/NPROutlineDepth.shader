// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "BlueWar/NPROutlineDepth"
{
	SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 150


		// ---- forward rendering base pass:
		Pass{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }

			Cull Off
			ZTest LEqual
			ZWrite On

			CGPROGRAM
			// compile directives
			#pragma vertex vert_surf
			#pragma fragment frag_surf
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
			#include "HLSLSupport.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "../ShadingCommon.cginc"
	
			
            struct Input 
            {
		        float2 uv_MainTex;
	        };

			// vertex-to-fragment interpolation data
			// no lightmaps:
	        struct v2f_surf 
            {
		        float4  pos			: SV_POSITION;
				float   linearDepth : TEXCOORD0;
	        };


	        // vertex shader
	        v2f_surf vert_surf(appdata_full v) 
            {
		        v2f_surf o;
		        UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
		        o.pos = UnityObjectToClipPos(v.vertex);

		        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 obj2Cam = (UnityWorldSpaceViewDir(worldPos));
				o.linearDepth = dot((float3)UNITY_MATRIX_V[2], obj2Cam);

		        return o;
	        }

	        // fragment shader
	        float4 frag_surf(v2f_surf IN) : SV_Target
            {
				float linearDepth = saturate(IN.linearDepth * 0.05f);
				return EncodeFloatToRGBA8(linearDepth);
	         }
		    ENDCG
	    }//pass
	}
	FallBack "Diffuse"
}
