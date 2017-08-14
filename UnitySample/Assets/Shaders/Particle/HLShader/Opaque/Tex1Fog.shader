// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HL/Opaque/Tex1Fog"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_Intensity ("Intensity", float) = 1
		_MainTex ("Main Tex", 2D) = "white" {}

		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", float) = 2 //Back
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Z Test", float) = 4 //LessEqual
		[Enum(Off, 0, On, 1)] _ZWrite("Z Write", float) = 0 //Off
	}

	CGINCLUDE
	ENDCG

	SubShader
	{
		Tags { "Queue" = "Geometry" }
		Pass
		{
			Tags { "LIGHTMODE"="Always" }
			Lighting Off
			Blend Off
			//Fog { Mode Off }
			Cull [_CullMode]
			ZTest [_ZTest]
			ZWrite [_ZWrite]

			CGPROGRAM
			#include "../HLInclude.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.color = i.color * _Color;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : COLOR0
			{
				fixed4 color = i.color * _Intensity;
				color *= tex2D(_MainTex, i.uv);
				return color;
			}
	
			ENDCG
		} 
	}
	//Fallback "VertexLit"
}