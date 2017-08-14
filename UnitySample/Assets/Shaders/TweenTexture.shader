Shader "Unlit/TweenTexture"
{
	Properties {
		_MainTex ("Day Texture", 2D) = "white" {}
		_BlendTex ("Night Texture", 2D) = "white" {}
		//[Toggle] _GloableNightFrac ("Is Night", Range(0,1)) = 0.0
		_Metallic("Metallic", Range(0.0, 1.0)) = 0.0
		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
	}

	SubShader
	{
		Tags {"RenderType"="Opaque"}
         LOD 200
         CGPROGRAM
         #pragma surface surf NoLighting noambient
		 #include "UnityPBSLighting.cginc"
         
         sampler2D _MainTex;
         sampler2D _BlendTex;
         
		 half _Metallic;
		 half _Glossiness;

		 uniform float _GloableNightFrac;
         
         struct Input {
             float2 uv_MainTex;
             float2 uv_BlendTex;
         };         
         
		fixed4 LightingNoLighting(SurfaceOutputStandard s, fixed3 lightDir, fixed atten){
             fixed4 c;
             c.rgb = s.Albedo; 
             c.a = s.Alpha;
             return c;
         }

         void surf(Input IN, inout SurfaceOutputStandard o) {
			half4 c1 = tex2D(_MainTex, IN.uv_MainTex);
			half4 c2 = tex2D(_BlendTex, IN.uv_BlendTex);
			o.Albedo = lerp(c1.rgb, c2.rgb, _GloableNightFrac); // half3(_GloableNightFrac, _GloableNightFrac, _GloableNightFrac); //
			o.Alpha = lerp(c1.a, c2.a, _GloableNightFrac); 
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
         }
         
         ENDCG
         
     }
     Fallback "Diffuse"
}
