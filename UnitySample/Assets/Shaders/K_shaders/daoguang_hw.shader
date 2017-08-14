// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Effects/daoguang_hw"
{
	Properties
	{
		_Diffuse("Diffuse", 2D) = "white" {}
		_NoiseTex("NoiseTexture", 2D) = "white" {}

		_DistortStrength("扭曲系数", Range(0,1)) = 0.2
		_DistortTimeFactor("扭曲快慢", Range(0,1)) = 1
		_Color("Color", Color) = (0.8,0.3,0.1,1)
		
		_Intensity("强度",Float) = 1

		_EdgeIntensity("勾边强度",Float) = 1
		_EdgeColor("勾边颜色", Color) = (0,0,1,1)
		_EdgeWidth("勾边宽度", Float) = 3
		[Toggle] _Distort("是否热扭曲", Float) = 0
	}
	SubShader
		{
			Tags
			{
				"RenderType" = "Transparent"
				"Queue" = "Transparent+100"
			}
			
			ZWrite Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
			//GrabPass
			GrabPass
			{
				//此处给出一个抓屏贴图的名称，抓屏的贴图就可以通过这张贴图来获取，而且每一帧不管有多个物体使用了该shader，只会有一个进行抓屏操作
				//如果此处为空，则默认抓屏到_GrabTexture中，但是据说每个用了这个shader的都会进行一次抓屏！
				"_GrabTempTex"
			}

			Pass
			{
				CGPROGRAM
				#pragma shader_feature _DISTORT_ON
#if _DISTORT_ON
				sampler2D _GrabTempTex;
				float4 _GrabTempTex_ST;
#endif
				sampler2D _NoiseTex;
				float4 _NoiseTex_ST;
				float _DistortStrength;
				float _DistortTimeFactor;
				sampler2D _Diffuse;
				float4 _Diffuse_ST;
				float4 _Color;
				float4 _EdgeColor;
				float _EdgeWidth;
				float _Intensity;
				float _EdgeIntensity;
				#include "UnityCG.cginc"

				struct VertexInput {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float2 texcoord : TEXCOORD0;
					float4 vertexColor : COLOR;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					float4 grabPos : TEXCOORD1;
					float4 vertexColor : COLOR;
				};

				v2f vert(VertexInput v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.grabPos = ComputeGrabScreenPos(o.pos);
					o.uv = TRANSFORM_TEX(v.texcoord, _NoiseTex);
					o.vertexColor = v.vertexColor;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
#if _DISTORT_ON
					//首先采样噪声图，采样的uv值为粒子系统输出的color的alpha通道，输出一个噪声图中的随机值，乘以一个扭曲快慢系数
					float4 offset = tex2D(_NoiseTex, i.uv - i.vertexColor.aa * _DistortTimeFactor);
					//用采样的噪声图输出作为下次采样Grab图的偏移值，此处乘以一个扭曲力度的系数
					i.grabPos.xy -= offset.xy * _DistortStrength;
					//uv偏移后去采样贴图即可得到扭曲的效果
					fixed4 distortColor = tex2Dproj(_GrabTempTex, i.grabPos);
#endif
					//指定的颜色根据alpha值来渲染图片
					fixed4 diffuseColor = tex2D(_Diffuse, i.uv);
					fixed4 emmisiveColor = fixed4(_Color.rgb  * diffuseColor.r ,0);
					fixed4 resultColor = emmisiveColor * _Intensity;

					float4 noiseColor = tex2D(_NoiseTex, i.uv);
					float dissolveFactor = i.vertexColor.a;
					
					if (diffuseColor.a == 0)
					{
						//如果原图alpha为0，此处不做消融
						discard;
					}

	
					float EdgeFactor = saturate((1 - dissolveFactor - noiseColor.a) / (_EdgeWidth));
					_EdgeColor = _EdgeColor *_EdgeIntensity;					
					resultColor = lerp(resultColor, _EdgeColor, 1 - EdgeFactor);
					
					//还未开始消融的部分逐渐变透(alpha变小)
					resultColor.a = lerp(diffuseColor.a * EdgeFactor , 0, dissolveFactor );
					if (EdgeFactor > 0 && EdgeFactor < 1) resultColor.a = 1;//红色边缘不做alpha

#if _DISTORT_ON
					//if (EdgeFactor > 0 && EdgeFactor < 1) resultColor.a = 1;//红色边缘不做alpha
					//resultColor.a = 1 - step(EdgeFactor, 0)*step(1, EdgeFactor);
					resultColor.rgb = resultColor.rgb * resultColor.a + (1 - resultColor.a)*distortColor.rgb;
					resultColor.a = 1;
#endif
					return resultColor;
					
					
				}

				#pragma vertex vert
				#pragma fragment frag
				ENDCG
			}
		}	
	
}