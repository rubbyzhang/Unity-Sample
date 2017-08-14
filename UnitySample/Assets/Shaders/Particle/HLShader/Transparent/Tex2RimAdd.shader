// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HL/Transparent/Tex2RimAdd"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_Intensity ("Intensity", float) = 1
        _MainTex ("Main Tex", 2D) = "white" {}
		_USpeed ("USpeed", Float) = 0
        _VSpeed ("VSpeed", Float) = 0
        _AddTex ("Add Tex", 2D) = "white" {}
		_USpeed1 ("USpeed1", Float) = 0
        _VSpeed1 ("VSpeed1", Float) = 0
		
		_RimColor ("Rim Color", Color) = (0.5,0.5,0.5,0.5)
		_InnerColor ("Inner Color", Color) = (0.5,0.5,0.5,0.5)
		_InnerColorPower ("Inner Color Power", Range(0.0,1.0)) = 0.5
		_RimPower ("Rim Power", Range(0.0,5.0)) = 2.5
		_AlphaPower ("Alpha Rim Power", Range(0.0,8.0)) = 4.0
		_AllPower ("All Power", Range(0.0, 10.0)) = 1.0
		
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
			
			float4 _RimColor;
			float _RimPower;
			float _AlphaPower;
			float _AlphaMin;
			float _InnerColorPower;
			float _AllPower;
			float4 _InnerColor;

			struct appdata
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
				half3 normal: TEXCOORD0;
				half3 viewDir : TEXCOORD1;
                float2 uv[2] : TEXCOORD2;
			};

			v2f vert(appdata i)
			{
				v2f o;
				o.color = i.color * _Color;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv[0] = TRANSFORM_TEX(i.uv, _MainTex);
				o.uv[1] = TRANSFORM_TEX(i.uv, _AddTex);

				float3 worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
				o.normal = normalize(mul(unity_ObjectToWorld, float4(i.normal,0)).xyz);

				//main tex uv offset
				o.uv[0] = Calculate_UVAnim(o.uv[0], _USpeed, _VSpeed);

				//Add tex uv offset
				o.uv[1] = Calculate_UVAnim(o.uv[1], _USpeed1, _VSpeed1);

				return o;
			}

			fixed4 frag(v2f i) : COLOR0
			{
				fixed4 color = i.color * _Intensity;
				fixed4 mainColor = tex2D(_MainTex, i.uv[0]);
				fixed4 addColor = tex2D(_AddTex, i.uv[1]);
				mainColor.rgb += addColor.rgb * addColor.a;
				color *= mainColor;

				half rim = 1.0 - saturate(dot (i.viewDir, i.normal));
				half3 rimColor = _RimColor.rgb * pow (rim, _RimPower)*_AllPower+(_InnerColor.rgb*2*_InnerColorPower);
				half rimA = (pow (rim, _AlphaPower))*_AllPower;
				color *= fixed4(rimColor, rimA);

				return color;
			}
	
			ENDCG
		} 
	}
	//Fallback "VertexLit"
}