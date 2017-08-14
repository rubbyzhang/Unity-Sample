// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "BlueWar/FarModelEnv"
{
  	Properties {
   		_Color ("Main Color", Color) = (1, 1, 1, 1)
   		_MainTex ("Base (RGB)", 2D) = "white" {}
   		_LightMap ("Lightmap (RGB)", 2D) = "black" {}
 	}

 	SubShader {
 		LOD 200
 		Tags { "RenderType" = "Opaque" }

 		CGPROGRAM
 		#pragma surface surf Lambert vertex:vert

 		sampler2D _MainTex;
		sampler2D _LightMap;
		fixed4 _Color;

		fixed4 _FarModelLight;
		fixed _FarModelFogIntensity;

 		struct Input {
 			float2 uv_MainTex;
 			float2 uv2_LightMap;
 			float4 dir;
 		};

		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.dir = mul(unity_ObjectToWorld, v.vertex);
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
	  		float4 color = tex2D (_MainTex, IN.uv_MainTex);    
	  		color *= _Color * _FarModelLight;

        	half fog = 1 - saturate((normalize(IN.dir).y) / _FarModelFogIntensity); // fog vanishes upwards
			color = lerp(color, unity_FogColor, fog * fog); // blend skybox with fog

	  		o.Albedo = color.rgb;
	  		half4 lm = tex2D (_LightMap, IN.uv2_LightMap);
	  		o.Emission = lm.rgb*o.Albedo.rgb;
	  		o.Alpha = lm.a * _Color.a;
		}

		ENDCG
	}
}

