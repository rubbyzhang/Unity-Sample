Shader "Hidden/MaskBloom"
{
	Properties {
		_MainTex("Texture", 2D) = "white" {}
	}

	SubShader
	{
		Cull Off ZWrite Off ZTest Always Blend off

		CGINCLUDE
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma target 3.0
		#include "UnityCG.cginc"
		// #define MASKBLOOM_OVERLAY

		struct v2f_blur {
			half4 pos : SV_POSITION;
			half4 uv : TEXCOORD0;
			half4 uv01 : TEXCOORD1;
			half4 uv23 : TEXCOORD2;
			half4 uv45 : TEXCOORD3;
			half4 uv67 : TEXCOORD4;
		};

		half4 _MainTex_TexelSize;
		sampler2D _MainTex;
		sampler2D _BlurTex;
		sampler2D _BloomScreenTex;

		half   _bloomIntensity;
		half4  _bloomBlurOffsets;
		fixed4 _bloomRGBThreshold;

		struct vsin {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct vs2psDown {
			float4 vertex : POSITION;
			float2 uv[4] : TEXCOORD0;
		};

		inline fixed ComputeBloomFactor(fixed4 c)
		{
			return Luminance(c.rgb) * c.a;
		}

		vs2psDown vertDownsample(vsin IN) {
			vs2psDown OUT;
			OUT.vertex = UnityObjectToClipPos(IN.vertex);
			OUT.uv[0] = IN.uv;
			OUT.uv[1] = IN.uv + float2(-0.5, -0.5) * _MainTex_TexelSize.xy;
			OUT.uv[2] = IN.uv + float2( 0.5, -0.5) * _MainTex_TexelSize.xy;
			OUT.uv[3] = IN.uv + float2(-0.5,  0.5) * _MainTex_TexelSize.xy;
			return OUT;
		}

		fixed4 fragDownsample(vs2psDown IN) : COLOR {
			fixed4 c = 0;
			c += tex2D(_MainTex, IN.uv[0]);
			c += tex2D(_MainTex, IN.uv[1]);
			c += tex2D(_MainTex, IN.uv[2]);
			c += tex2D(_MainTex, IN.uv[3]);
			return c * 0.25;
		}

		fixed4 fragMask(v2f_img IN) : COLOR {
			fixed4 c = tex2D(_MainTex, IN.uv.xy);
			c.rgb = max(0, (c.rgb - _bloomRGBThreshold.rgb) * ComputeBloomFactor(c));
			return c;
		}

		v2f_blur vertGaussBlurLinearSampling(appdata_img v) {
			v2f_blur o;
			o.pos = UnityObjectToClipPos(v.vertex);

			const float gWeights[2] = { 0.44908, 0.05092 };
			const float gOffsets[2] = { 0.53805, 2.06278 };
			o.uv01 = float4(v.texcoord.xy + gOffsets[0] * _bloomBlurOffsets.xy, gWeights[0], 0);
			o.uv23 = float4(v.texcoord.xy - gOffsets[0] * _bloomBlurOffsets.xy, gWeights[0], 0);
			o.uv45 = float4(v.texcoord.xy + gOffsets[1] * _bloomBlurOffsets.xy, gWeights[1], 0);
			o.uv67 = float4(v.texcoord.xy - gOffsets[1] * _bloomBlurOffsets.xy, gWeights[1], 0);

			return o;		
		}

		fixed4 fragGaussBlurLinearSampling(v2f_blur i) : SV_Target
		{
			fixed4 colOut = fixed4( 0, 0, 0, 0 );

			colOut += (tex2D(_MainTex, i.uv01.xy) + tex2D(_MainTex, i.uv23.xy)) * i.uv01.z;
			colOut += (tex2D(_MainTex, i.uv45.xy) + tex2D(_MainTex, i.uv67.xy)) * i.uv45.z;

			return colOut;
		}

		v2f_blur vertWithMultiCoords2 (appdata_img v) {
			v2f_blur o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv.xy = v.texcoord.xy;
			o.uv01 =  v.texcoord.xyxy + _bloomBlurOffsets.xyxy * half4(1,1, -1,-1);
			o.uv23 =  v.texcoord.xyxy + _bloomBlurOffsets.xyxy * half4(1,1, -1,-1) * 2.0;
			o.uv45 =  v.texcoord.xyxy + _bloomBlurOffsets.xyxy * half4(1,1, -1,-1) * 3.0;
			o.uv67 =  v.texcoord.xyxy + _bloomBlurOffsets.xyxy * half4(1,1, -1,-1) * 4.0;
			return o;
		}

		half4 fragGaussBlur(v2f_blur i) : SV_Target
		{
			half4 col   = tex2D (_MainTex, i.uv);
			half4 color = half4 (0,0,0,0);
			color += 0.225 * col;
			color += 0.150 * tex2D (_MainTex, i.uv01.xy);
			color += 0.150 * tex2D (_MainTex, i.uv01.zw);
			color += 0.110 * tex2D (_MainTex, i.uv23.xy);
			color += 0.110 * tex2D (_MainTex, i.uv23.zw);
			color += 0.075 * tex2D (_MainTex, i.uv45.xy);
			color += 0.075 * tex2D (_MainTex, i.uv45.zw);
			color += 0.0525 * tex2D (_MainTex, i.uv67.xy);
			color += 0.0525 * tex2D (_MainTex, i.uv67.zw);
			return half4(color.rgb, col.a);
		}

		fixed4 fragKawaseBlur(v2f_img i) : SV_Target
		{
			fixed4 o = 0;
			o += tex2D(_MainTex, i.uv + (float2( _bloomBlurOffsets.x + 0.5, _bloomBlurOffsets.y + 0.5) * _MainTex_TexelSize.xy));
			o += tex2D(_MainTex, i.uv + (float2(-_bloomBlurOffsets.x - 0.5, _bloomBlurOffsets.y + 0.5) * _MainTex_TexelSize.xy));
			o += tex2D(_MainTex, i.uv + (float2(-_bloomBlurOffsets.x - 0.5,-_bloomBlurOffsets.y - 0.5) * _MainTex_TexelSize.xy));
			o += tex2D(_MainTex, i.uv + (float2( _bloomBlurOffsets.x + 0.5,-_bloomBlurOffsets.y - 0.5) * _MainTex_TexelSize.xy));
			return o / 4;
		}

		#ifdef MASKBLOOM_OVERLAY
		  #define ScreenTex _BloomScreenTex
		#else
		  #define ScreenTex _MainTex
		#endif

		v2f_img vertBlit(appdata_img v) {
			v2f_img o;
			o.pos = v.vertex * float4(2, 2, 0, 0) + float4(0, 0, 0, 1);
		#if UNITY_UV_STARTS_AT_TOP
			o.uv = v.texcoord * float2(1, -1) + float2(0, 1);
		#else
			o.uv = v.texcoord;
		#endif
			return o;
		}

		v2f_img vertDraw(appdata_img v) {
		#ifdef MASKBLOOM_OVERLAY
			return vertBlit(v);
		#else
			return vert_img(v);
		#endif
		}

		fixed4 fragScreen(v2f_img i) : SV_Target {
			fixed4 screencolor = tex2D(ScreenTex, i.uv.xy);
			fixed4 addedbloom = tex2D(_BlurTex, i.uv.xy);
			fixed4 result = 1 - (1 - addedbloom * _bloomIntensity) * (1 - screencolor);
			return result; // lerp(screencolor, result, addedbloom.a);
		}

		fixed4 fragAdd(v2f_img i) : SV_Target {
			fixed4 screencolor = tex2D(ScreenTex, i.uv.xy);
			fixed4 addedbloom = tex2D(_BlurTex, i.uv.xy);
			fixed4 result = _bloomIntensity * addedbloom + screencolor;
			return result; // lerp(screencolor, result, addedbloom.a);
		}

		fixed4 fragBlit(v2f_img i) : SV_Target {
			return tex2D(_BloomScreenTex, i.uv.xy);
		}

		fixed4 fragDump(v2f_img i) : SV_Target {
			fixed4 screencolor = tex2D(_BloomScreenTex, i.uv.xy);
			return screencolor.a; // ComputeBloomFactor(screencolor);
		}
		ENDCG

		// 0 : Downsample
		Pass {
			CGPROGRAM
			#pragma vertex   vertDownsample
			#pragma fragment fragDownsample
			ENDCG
		}

		// 1 : Mask
		Pass {
			CGPROGRAM
			#pragma vertex   vert_img
			#pragma fragment fragMask
			ENDCG
		}

		// 2 : Separable Gaussian Blur
		Pass {
			CGPROGRAM
			// #pragma vertex vertWithMultiCoords2
			// #pragma fragment fragGaussBlur
			#pragma vertex   vertGaussBlurLinearSampling
			#pragma fragment fragGaussBlurLinearSampling
			ENDCG
		}

		// 3 : Kawase Blur
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment fragKawaseBlur
			ENDCG
		}		

		// 4 : Bloom (Screen)
		Pass {
			CGPROGRAM
			#pragma vertex vertDraw
			#pragma fragment fragScreen
			ENDCG
		}

		// 5 : Bloom (Add)
		Pass {
			CGPROGRAM
			#pragma vertex vertDraw
			#pragma fragment fragAdd
			ENDCG
		}

		// 6 : Blit to Screen
		Pass {
			CGPROGRAM
			#pragma vertex   vertBlit
			#pragma fragment fragBlit
			ENDCG
		}

		// 7 : DebugDraw
		Pass {
			CGPROGRAM
			#pragma vertex   vertBlit
			#pragma fragment fragDump
			ENDCG
		}
	}
}
