// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MV/Default"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		[Toggle]_MainTexGrey("Tex Grey",float) = 0
		_BrushTex("Brush Texture", 2D) = "white" {}

		_Color("Tint", Color) = (1,1,1,1)

		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255

		_ColorMask("Color Mask", Float) = 15

		_FadeSpeed("FadeSpeed",Float) = 1

		_SimulateProgress("SimulateProgress",Range(0,1.0)) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest[unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask[_ColorMask]

		Pass
		{
			CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color : COLOR;
				half2 uv0  : TEXCOORD0;
				half2 uv1  : TEXCOORD1;
			};

			fixed4 _Color;
			float _SimulateProgress;
			float _FadeSpeed;
			float _MainTexGrey;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BrushTex;
			float4 _BrushTex_ST;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.uv0 = TRANSFORM_TEX(IN.texcoord, _MainTex);
				OUT.uv1 = TRANSFORM_TEX(IN.texcoord, _BrushTex);
#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw - 1.0)*float2(-1, 1);
#endif
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 color = tex2D(_MainTex, IN.uv0) * IN.color;
				half4 brushColor = tex2D(_BrushTex, IN.uv1);

				if (_FadeSpeed < 1)
					_FadeSpeed = 1;

				float grey = dot(color.rgb, float3(0.299, 0.587, 0.114));
				float3 greyColor = float3(grey, grey, grey);

				float3 finalColor = color.rgb;
				if (_MainTexGrey != 0)
				{
					color.rgb = greyColor;
				}

				float currentFadeTime = clamp(clamp((_SimulateProgress * 2 - brushColor.a), 0, 1) * _FadeSpeed, 0, 1);
				color.a = currentFadeTime;

				return color;
			}
			ENDCG
		}
	}
}