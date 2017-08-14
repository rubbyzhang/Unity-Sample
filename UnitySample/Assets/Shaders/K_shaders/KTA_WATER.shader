Shader "KTA_WATER"
{
	Properties 
	{
	_MainColor("Main Color", COLOR) = ( .54, .95, .99, 0.5)
	_BumpTiling ("Bump Tiling", Vector) = (1.0 ,1.0, -2.0, 3.0)
	_BumpDirection ("Bump Direction & Speed", Vector) = (1.0 ,1.0, -1.0, 1.0)
	// _Texture1("_Texture1", 2D) = "black" {}
	_BumpMap1("_BumpMap1", 2D) = "black" {}
	_DepthMap("_Depth", 2D) = "white" {}
	_MainTexSpeed("_MainTexSpeed", Float) = 0
	_DistortionMap("_DistortionMap", 2D) = "black" {}
	_DistortionSpeed("_DistortionSpeed", Float) = 0
	_DistortionPower("_DistortionPower", Range(0,0.02) ) = 0
	_Specular("_Specular", Range(0,7) ) = 1
	_Gloss("_Gloss", Range(0.3,2) ) = 0.3
	_Opacity("_Opacity", Range(-0.2,1) ) = 0
	_ReflectionColor("Reflection color", COLOR) = ( .54, .95, .99, 0.5)
	}
	
	SubShader 
	{
		Tags
		{
		"Queue"="Transparent"
		"IgnoreProjector"="True"
		"RenderType"="Transparent"
		}

		
		Cull Back
		ZWrite On
		ZTest LEqual
		ColorMask RGBA
		Blend SrcAlpha OneMinusSrcAlpha
		
		
		CGPROGRAM
		#pragma surface surf BlinnPhongEditor alpha:blend
		#pragma target 3.0
		
		uniform float4 _MainColor;
		uniform float4 _BumpTiling;
		uniform float4 _BumpDirection;
		uniform float4 _ReflectionColor;
		
		// uniform sampler2D _Texture1;
		uniform sampler2D _BumpMap1;
		uniform sampler2D _DepthMap;
		half _MainTexSpeed;
		uniform sampler2D _DistortionMap;
		half _DistortionSpeed;
		half _DistortionPower;
		fixed _Specular;
		fixed _Gloss;
		float _Opacity;

		struct EditorSurfaceOutput {
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half3 Gloss;
			half Specular;
			half Alpha;
			half4 Custom;
		};
		
			
		inline fixed4 LightingBlinnPhongEditor_PrePass (EditorSurfaceOutput s, fixed4 light)
		{
			fixed3 spec = light.a * s.Gloss;
			fixed4 c;
			c.rgb = (s.Albedo * light.rgb + light.rgb * spec * 0.75f);
			c.a = s.Alpha;
			return c;
		}

		inline fixed4 LightingBlinnPhongEditor (EditorSurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
		{
			fixed3 h = normalize (lightDir + viewDir);
			
			fixed diff = max (0, dot ( lightDir, s.Normal ));
			
			float nh = max (0, dot (s.Normal, h));
			float spec = pow (nh, s.Specular*128.0);
			
			fixed4 res;
			res.rgb = _LightColor0.rgb * diff;
			res.w = spec * Luminance (_LightColor0.rgb);
			res *= atten * 2.0;

			return LightingBlinnPhongEditor_PrePass( s, res );
		}
		
		struct Input {
			
			float2 uv_DistortionMap;
			// float2 uv_Texture1;
			// float2 uv_Texture2;
			float2 uv_BumpMap1;
			// float2 uv_BumpMap2;
			float2 uv_DepthMap;
			float3 worldPos;
			float3 viewDir;
		};

		void surf (Input IN, inout EditorSurfaceOutput o) {
			o.Normal = float3(0.0,0.0,1.0);
			o.Alpha = 1.0;
			o.Albedo = 0.0;
			o.Emission = 0.0;
			o.Gloss = 0.0;
			o.Specular = 0.0;
			o.Custom = 0.0;
			
			half2 tileableUv = IN.uv_BumpMap1.xy;
			half4 bumpCoords = (tileableUv.xyxy + _Time.xxxx * _BumpDirection.xyzw) * _BumpTiling.xyzw;
						
			// Animate distortionMap 
			float DistortSpeed=_DistortionSpeed * _Time;
			float2 DistortUV=(IN.uv_DistortionMap.xy) + DistortSpeed;
			// Create Normal for DistorionMap
			float4 DistortNormal =  tex2D(_DistortionMap,DistortUV);
			// Multiply Tex2DNormal effect by DistortionPower
			float2 FinalDistortion = DistortNormal.xy * _DistortionPower;
			
					
			// Animate MainTex
			//float Multiply2 = _Time * _MainTexSpeed;
			//float2 MainTexUV = (IN.uv_Texture1.xy) + Multiply2; 
			
			// Apply Distorion in MainTex
			float4 Tex2D0 = _MainColor; //tex2D(_Texture1,MainTexUV + FinalDistortion);
						
			// Merge MainTex and Texture2
			float4 FinalDiffuse = Tex2D0;
			FinalDiffuse.xy = FinalDiffuse.xy + FinalDistortion.xy;  
			
			
			// Animate BumpMap1
			half4 Tex2D3 = tex2D(_BumpMap1, bumpCoords.xy + FinalDistortion);
			half4 Tex2D4 = tex2D(_BumpMap1, bumpCoords.zw + FinalDistortion);
			
			// Get Average from BumpMap1 and BumpMap2
			fixed4 AvgBump = (Tex2D3 + Tex2D4) * 0.5f;
			
			
			// Unpack Normals
			half3 UnpackNormal1 = half3(UnpackNormal(AvgBump).xyz);
		
			FinalDiffuse = lerp(_ReflectionColor, FinalDiffuse, saturate(dot(IN.viewDir, UnpackNormal1)));
			
			o.Albedo = FinalDiffuse;
			o.Normal = UnpackNormal1;
			o.Specular = _Gloss;
			o.Gloss = _Specular;
			o.Alpha = tex2D(_DepthMap, IN.uv_DepthMap.xy).r * _Opacity;
			o.Normal = normalize(o.Normal);
		}
	ENDCG
	}
	Fallback "Diffuse"
}