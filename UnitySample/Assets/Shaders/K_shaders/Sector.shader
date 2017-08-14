// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Sector" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Center("_Center", Vector) = (0.5, 0, 0, 0)
		_Angle("Angle",Range(0, 1.57)) = 0
	}
	
    SubShader {
   		
   		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Cull Back
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend SrcAlpha One  
		
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _Center;
            float _Angle;
            
            struct v2f {
                float4  pos : SV_POSITION;
                float2  uv : TEXCOORD0;
            } ;
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
            
            float4 frag (v2f i) : COLOR
            {
                float4 texCol = tex2D(_MainTex,i.uv);
                
            	if( (i.uv.y - _Center.y) < (i.uv.x - _Center.x) * tan(_Angle))
            		texCol.a = 0;
        		if( (i.uv.y - _Center.y) < -(i.uv.x - _Center.x) * tan(_Angle))
            		texCol.a = 0;
            		
                return texCol;
            }
            ENDCG
        }
	} 
	FallBack "Diffuse"
}
