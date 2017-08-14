Shader "HL/Test/Skybox todel" {
Properties {
	_Color ("Main Color", Color) = (1, 1, 1, 1)
	_Cube ("Cube Tex (RGB)", Cube) = "" {}
	_YRotate ("Y axis Rotate", Range(0.0, 6.28)) = 0.0
}

CGINCLUDE
		#include "UnityCG.cginc"
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma target 2.0
		
		fixed4 _Color;
		samplerCUBE _Cube;
		float _YRotate;
		
		const float4x4 _M1 = float4x4(
							  float4(0.7, 0.0, 0.7, 0.0),
							  float4(0.0, 1.0, 0.0, 0.0),
							  float4(-0.7, 0.0, 0.7, 0.0),
							  float4(0.0, 0.0, 0.0, 1.0));
		const float4x4 _M2 = float4x4(
							  float4(0.5, 0.0, 0.87, 0.0),
							  float4(0.0, 1.0, 0.0, 0.0),
							  float4(-0.87, 0.0, 0.5, 0.0),
							  float4(0.0, 0.0, 0.0, 1.0));


		struct appdata {
            float4 vertex : POSITION;
            float3 uv : TEXCOORD0;
         };

		struct v2f {
			float4  pos : SV_POSITION;
			float3  uv : TEXCOORD0;
		};

		v2f vert (appdata v)
		{
			v2f o;
			//float4x4 m = mul(_M, UNITY_MATRIX_MVP);
			float4x4 m = UNITY_MATRIX_MVP;
			o.pos = mul(m, v.vertex);
			o.uv = v.uv;
			return o;
		}

		fixed4 frag (v2f i) : COLOR
		{
			fixed4 c = texCUBE(_Cube, i.uv) * _Color;
			return c;
		}

ENDCG

SubShader {
	Tags { "Queue" = "Background-100"}
	Lighting Off
	ZWrite Off
	ZTest Off
	Blend Off
	Cull Off//Front
	Fog {Mode Off} //to add fog in shader

    Pass {
		Tags { "LIGHTMODE"="Always" }
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		ENDCG
    }
}

//Fallback "VertexLit"
} 