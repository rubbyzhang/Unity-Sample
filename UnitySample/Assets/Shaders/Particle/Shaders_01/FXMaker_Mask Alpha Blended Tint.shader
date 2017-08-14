Shader "FXMaker/Mask Alpha Blended Tint" {
	Properties {
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_Mask ("Mask", 2D) = "white" {}

		[Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 0
	}

	Category {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
// 		AlphaTest Greater .01
// 		ColorMask RGB
		Cull [_Cull] Lighting Off ZWrite [_ZWrite] Fog { Color (0,0,0,0) }
		BindChannels {
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}
		
		// ---- Dual texture cards
		SubShader {
			Pass {
				SetTexture [_MainTex] {
					constantColor [_TintColor]
					combine constant * primary
				}
	 			SetTexture [_Mask] {combine texture * previous}
				SetTexture [_MainTex] {
					combine texture * previous DOUBLE
				}
			}
		}
		
		// ---- Single texture cards (does not do color tint)
		SubShader {
			Pass {
				SetTexture [_Mask] {combine texture * primary}
//				SetTexture [_Mask] {combine texture DOUBLE}
				SetTexture [_MainTex] {
					combine texture * previous
				}
			}
		}
	}
}
