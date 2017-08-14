// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MV/MultiLayer"
{
	Properties
	{
		//Main tex
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		//layer 1
		_TexLayerLine("Texture Layer Line", 2D) = "white" {}
		//layer 2
		_TexLayerColor("Texture Layer Color", 2D) = "white" {}
		//layer 3
		[Toggle]_MainTexGrey("Use Grey",float) = 1
		
		//layer 1
		_BrushTexLine("Brush Texture Line", 2D) = "white" {}
		//layer 2
		_BrushTexGrey("Brush Texture Gery", 2D) = "white" {}
		//layer 3
		_BrushTexColor("Brush Texture Color", 2D) = "white" {}

		//layer 1
		_SimulateProgressToLine("SimulateProgressLine",Range(0,1.0)) = 0
		//layer 2
		_SimulateProgressToGrey("SimulateProgressGrey",Range(0,1.0)) = 0
		//layer 3
		_SimulateProgressToColor("SimulateProgressColor",Range(0,1.0)) = 0
		
		_FadeSpeedLine("FadeSpeedLine",Float) = 1
		_FadeSpeedGrey("FadeSpeedGrey",Float) = 1
		_FadeSpeedColor("FadeSpeedColor",Float) = 1

		_Color("Tint", Color) = (1,1,1,1)

		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255

		_ColorMask("Color Mask", Float) = 15
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
			
			//Main
			sampler2D _MainTex;
			float4 _MainTex_ST;
			//layer 1
			sampler2D _TexLayerLine;
			sampler2D _BrushTexLine;
			float _SimulateProgressToLine;
			//layer 2
			float _MainTexGrey;
			sampler2D _BrushTexGrey;
			float _SimulateProgressToGrey;
			//layer 3
			sampler2D _TexLayerColor;
			sampler2D _BrushTexColor;
			float _SimulateProgressToColor;

			float _FadeSpeedLine;
			float _FadeSpeedGrey;
			float _FadeSpeedColor;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.uv0 = TRANSFORM_TEX(IN.texcoord, _MainTex);
#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw - 1.0)*float2(-1, 1);
#endif
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 mainColor = tex2D(_MainTex, IN.uv0) * IN.color;

				half4 lineColor = tex2D(_TexLayerLine, IN.uv0) * IN.color;
				half4 trueColor = tex2D(_TexLayerColor, IN.uv0) * IN.color;

				float grey = dot(trueColor.rgb, float3(0.299, 0.587, 0.114));
				float3 greyColor = float3(grey, grey, grey);


				half4 brushColorLine = tex2D(_BrushTexLine, IN.uv0);
				half4 brushColorGrey = tex2D(_BrushTexGrey, IN.uv0);
				half4 brushColorColor = tex2D(_BrushTexColor, IN.uv0);


				float fadeTimeLine = clamp(clamp((_SimulateProgressToLine * 2 - brushColorLine.a), 0, 1) * _FadeSpeedLine, 0, 1);
				mainColor.rgb = lerp(mainColor.rgb, lineColor.rgb, fadeTimeLine);

				float fadeTimeGrey = clamp(clamp((_SimulateProgressToGrey * 2 - brushColorGrey.a), 0, 1) * _FadeSpeedGrey, 0, 1);
				mainColor.rgb = lerp(mainColor.rgb, greyColor.rgb, fadeTimeGrey);

				float fadeTimeColor = clamp(clamp((_SimulateProgressToColor * 2 - brushColorColor.a), 0, 1) * _FadeSpeedColor, 0, 1);
				mainColor.rgb = lerp(mainColor.rgb, trueColor.rgb, fadeTimeColor);

				return mainColor;
			}
			ENDCG
		}
	}
}