Shader "ImageEffect/Grayscale EffectEx" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Percent( "Percent", Range(0,1)) = 1.0
}

SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }
				
CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest 
#include "UnityCG.cginc"

uniform sampler2D _MainTex;
uniform float _Percent;

fixed4 frag (v2f_img i) : COLOR
{
	fixed4 original = tex2D(_MainTex, i.uv);
	fixed grayscale = Luminance(original.rgb);
	fixed4 output = lerp( original, fixed4(grayscale,grayscale,grayscale,grayscale), _Percent );
	output.a = 1.0f; 
	return output;
}  
ENDCG

	}
}

Fallback off

}