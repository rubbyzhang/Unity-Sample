// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Particles/MeshBillboard Additive" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0

	[Toggle(AXIAL_BILLBOARD)] _UseAxialBillboard ("Axial Billboarding?", Float) = 0
	[Toggle(USE_AUTOFADEOUT)] _UseAutoFadeOut ("Auto fade out as they get close to the camera?", Float) = 0
}

Category {
	Tags { "Queue"="Transparent+1" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True" }
	Blend SrcAlpha One
	ColorMask RGB
	Cull Off
	Lighting Off ZWrite Off
	
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles
			#pragma multi_compile_fog
			#pragma multi_compile _ AXIAL_BILLBOARD
			#pragma multi_compile _ USE_AUTOFADEOUT
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
			float4 _MainTex_ST; 

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				#ifdef SOFTPARTICLES_ON
				float4 projPos : TEXCOORD2;
				#endif
			};
			
			v2f vert (appdata_t v)
			{
				v2f o;

                float3 objViewDir = normalize(-mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1)).xyz);

			#if AXIAL_BILLBOARD
				objViewDir.z = 0;
			#endif
               
                float3 up = float3(0, 0, -1);
 
                // Create LookAt matrix
                float3 zaxis = objViewDir;
                float3 xaxis = normalize(cross(up, zaxis));
                float3 yaxis = cross(zaxis, xaxis);
 
                float4x4 lookatMatrix = {
                    xaxis.x, yaxis.x, zaxis.x, 0,
                    xaxis.y, yaxis.y, zaxis.y, 0,
                    xaxis.z, yaxis.z, zaxis.z, 0,
                    0, 0, 0,  1
                };
               
				v.vertex.z = -v.vertex.z;
				o.vertex = UnityObjectToClipPos(mul(lookatMatrix, v.vertex));

				#ifdef SOFTPARTICLES_ON
				o.projPos = ComputeScreenPos (o.vertex);
				COMPUTE_EYEDEPTH(o.projPos.z);
				#endif

			#if USE_AUTOFADEOUT
				float4 viewPos = mul(UNITY_MATRIX_MV, v.vertex);
				float alpha = (-viewPos.z - _ProjectionParams.y)/0.5f;
				alpha = min(alpha, 1);
				o.color = fixed4(v.color.rgb, v.color.a * alpha);
			#else
				o.color = v.color;
			#endif
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			sampler2D_float _CameraDepthTexture;
			float _InvFade;
			
			fixed4 frag (v2f i) : SV_Target
			{
				#ifdef SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				float partZ = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));
				i.color.a *= fade;
				#endif
				
				fixed4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode
				return col;
			}
			ENDCG 
		}
	}	
}
}
