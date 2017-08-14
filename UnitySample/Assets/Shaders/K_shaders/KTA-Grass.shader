// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "KTA/Grass" {
Properties {
	_MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
	_Range ("Range", float) = 0.5
	_Speed ("Speed", float) = 0.5
	_Cutoff("Cutoff", float) = 0
}



SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 100
	
	//ZWrite On
	ZTest LEqual
	Blend SrcAlpha OneMinusSrcAlpha 
	
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float4 color: COLOR;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				float4 color: COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Range;
			float _Speed;
			
			
			v2f vert (appdata_t v)
			{
				v2f o;
//				realWaveAndDistance = _WaveAndDistance * sin(_Time.x);
//				float waveAmount = v.color.a * realWaveAndDistance.z;
//				v.color = MyTerrainWaveGrass (v.vertex, waveAmount, v.color);
				
				
				
				//v.vertex.z += sin(_Time.y);
				
				float param = v.color.a;
				
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				
				//vert.x += _SinTime.w;
				
				o.vertex = mul(UNITY_MATRIX_MV, v.vertex);
				o.vertex.x += sin(_Time.y*_Speed + worldPos.x * 0.5) * _Range * param;
				o.vertex = mul(UNITY_MATRIX_P, o.vertex);
				
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			float _Cutoff;
			
			fixed4 frag (v2f i) : Color
			{
				fixed4 col = tex2D(_MainTex, i.texcoord);
				if(col.a < _Cutoff)
					discard;
				
				return col;
			}
		ENDCG
	}
}

}
