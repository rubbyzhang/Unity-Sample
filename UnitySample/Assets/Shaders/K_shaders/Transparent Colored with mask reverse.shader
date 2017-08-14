// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Transparent Colored with mask reverse" 
{
  Properties 
  {
    _MainTex ("Base (RGB), Alpha (A)", 2D) = "white" {}
    _MaskTex ("_MaskTex", 2D) = "white" {}
    _MaskTex2 ("_MaskTex2", 2D) = "white" {}
    _CenterPosX ("Center Pos X", float ) = 0.5
    _CenterPosY ("Center Pos Y", float ) = 0.5
    _RangeX ("Range X", float) = 0.00
    _RangeY ("Range Y", float) = 0.00
    _RangeX2 ("Range X2", float) = 0.00
    _RangeY2 ("Range Y2", float) = 0.00
  }

  SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Offset -1, -1
		Blend SrcAlpha OneMinusSrcAlpha

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
				fixed4 color : COLOR;
			};
	
			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
	
			sampler2D _MainTex;
			sampler2D _MaskTex;			
			sampler2D _MaskTex2;			
			float _CenterPosX;
			float _CenterPosY;
			float _RangeX;
			float _RangeY;
			float _RangeX2;
			float _RangeY2;
				
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color;
				return o;
			}
				
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.texcoord) ;
				float u = (i.texcoord.x-(_CenterPosX-_RangeX)) / (2*_RangeX);
				float v = (i.texcoord.y-(_CenterPosY-_RangeY)) / (2*_RangeY);
				fixed4 mask = tex2D(_MaskTex, float2(u,v));
				
				float u2 = (i.texcoord.x-(_CenterPosX-_RangeX2)) / (2*_RangeX2);
				float v2 = (i.texcoord.y-(_CenterPosY-_RangeY2)) / (2*_RangeY2);
				fixed4 mask2 = tex2D(_MaskTex2, float2(u2,v2));
				if(u >= 0.0 && u <= 1.0 && v >= 0.0 && v <= 1.0)
					col.a = col.a * (1 - mask.a);
				if(u2 >= 0.0 && u2 <= 1.0 && v2 >= 0.0 && v2 <= 1.0)
					col.a = col.a * (1 - mask2.a);
//				if (i.texcoord.x > _CenterPosX - _RangeX &&
//					i.texcoord.x < _CenterPosX + _RangeX &&
//					i.texcoord.y > _CenterPosY - _RangeY * sqrt(1 - (i.texcoord.x - _CenterPosX) * (i.texcoord.x- _CenterPosX) / _RangeX / _RangeX) && 
//					i.texcoord.y < _CenterPosY + _RangeY * sqrt(1 - (i.texcoord.x - _CenterPosX) * (i.texcoord.x - _CenterPosX)/ _RangeX / _RangeX)
//					)
//					col.a = 0;
				//if(mask.r < 0.1)
					//col.a = 0;
												
				return col * i.color;
			}
			ENDCG
		}
	}
  FallBack "Diffuse"
}
