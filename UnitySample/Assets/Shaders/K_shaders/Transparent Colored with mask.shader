Shader "Unlit/Transparent Colored with mask" 
{
	Properties 
 	{
		[Header(Properties)]
			_MainTex ("Mask (Greyscale)", 2D) = "white" {}
			_BaseTex ("Base (RGB)", 2D) = "black" {} 

		[Header(Render State)]
            [Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 0
            [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 0
            [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendMode ("SrcBlend Mode", Float) = 5
            [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendMode ("DstBlend Mode", Float) = 10			
  	}

  	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"
		}
		
		Cull [_Cull]
		Lighting Off
		ZWrite [_ZWrite]
		Fog { Mode Off }
		Offset -1, -1
		Blend [_SrcBlendMode] [_DstBlendMode]

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag				
			#include "UnityCG.cginc"
	
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};
	
			struct v2f
			{
				float4 vertex : SV_POSITION;
				half4 texcoord : TEXCOORD0;
			};
	
			sampler2D _MainTex;
			sampler2D _BaseTex;
			float4 _BaseTex_ST;
			float4 _MainTex_ST;
				
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _BaseTex);
				o.texcoord.zw = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
				
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 base = tex2D(_BaseTex, i.texcoord.xy);
				fixed4 mask = tex2D(_MainTex, i.texcoord.zw);

				return fixed4(base.rgb, mask.r);
			}
			ENDCG
		}
	}
}
