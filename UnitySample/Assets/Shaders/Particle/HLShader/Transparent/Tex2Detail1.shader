// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HL/Transparent/Tex2Detail1"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_Intensity ("Intensity", float) = 1
		_MainTex ("Main Tex", 2D) = "white" {}
		_AddTex ("Add Tex", 2D) = "white" {}
		_UVRotateSpeed ("UVRotateSpeed", Float) = 0

		[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Blend Op", float) = 0 //Add
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend Src Factor", float) = 5  //SrcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend Dst Factor", float) = 10 //OneMinusSrcAlpha
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", float) = 2 //Back
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Z Test", float) = 4 //LessEqual
		[Enum(Off, 0, On, 1)] _ZWrite("Z Write", float) = 0 //Off
	}

	CGINCLUDE
	ENDCG

	SubShader
	{
		Tags { "Queue" = "Transparent" }
		Pass
		{
			Tags { "LIGHTMODE"="Always" }
			Lighting Off
			Fog { Mode Off }
			BlendOp [_BlendOp]
			Blend [_BlendSrc] [_BlendDst]
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
                float2 uv[2] : TEXCOORD0;
				fixed4 color : COLOR;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.color = i.color * _Color;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv[0] = TRANSFORM_TEX(i.uv, _MainTex);
				o.uv[1] = TRANSFORM_TEX(i.uv, _AddTex);
				
				//main tex uv stay

				//Add tex uv rotate
				o.uv[1] = Calculate_UVRotate(o.uv[1], _UVRotateSpeed);

				return o;
			}

			fixed4 frag(v2f i) : COLOR0
			{
				fixed4 color = i.color * _Intensity;
				fixed4 mainColor = tex2D(_MainTex, i.uv[0]);
				fixed4 addColor = tex2D(_AddTex, i.uv[1]);
				mainColor = mainColor * addColor * (mainColor + addColor);
				color *= mainColor;
				return color;
			}
	
			ENDCG
		} 
	}
	//Fallback "VertexLit"
}