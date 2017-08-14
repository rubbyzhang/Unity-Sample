// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Outline/InkingOutline"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("OutlineColor", Color) = (0,0,0,1)
		_Factor ("Factor", Range(0,1)) = 0.032
		_OutlineWidth ("OutlineWidth", Range(0,100)) = 10
		
	}
	SubShader
	{
		Pass
		{
			Tags{"LightMode"="Always"}
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
            };

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Factor;
			float _OutlineWidth;
			float4 _Color;

			v2f vert(appdata_base v)
			{
				v2f o;
          
				o.pos = UnityObjectToClipPos ( v.vertex );
				float3 dir = normalize ( v.vertex.xyz );
				float3 dir2 = v.normal;
		
				dir = lerp ( dir, dir2, _Factor );
				dir = mul ( ( float3x3 ) UNITY_MATRIX_IT_MV, dir );
				float2 offset = TransformViewToProjection ( dir.xy );
				offset = normalize ( offset );
				float dist = distance ( mul (unity_ObjectToWorld, v.vertex ), _WorldSpaceCameraPos );
				o.pos.xy += offset * o.pos.z * _OutlineWidth / dist;
 
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _Color;
			}
			ENDCG
		}
		
		Pass 
		{    
			 CGPROGRAM

			 #pragma vertex vert  
			 #pragma fragment frag 

			 uniform sampler2D _MainTex;    
			 uniform float4 _MainTex_ST; 
				// tiling and offset parameters of property             

			 struct vertexInput {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			 };
			 struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
			 };

			 vertexOutput vert(vertexInput input) 
			 {
				vertexOutput output;

				output.tex = input.texcoord;
				output.pos = UnityObjectToClipPos(input.vertex);
				return output;
			 }

			 float4 frag(vertexOutput input) : COLOR
			 {
				return tex2D(_MainTex, 
				   _MainTex_ST.xy * input.tex.xy + _MainTex_ST.zw); 
				   // texture coordinates are multiplied with the tiling 
				   // parameters and the offset parameters are added
			 }

			 ENDCG
		}
		
    }    
}
