Shader "KTA/Cutout" {
Properties {
    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    _MyCutoff ("Alpha cutoff", Range(0,1)) = 0.5
}
 
SubShader {
    Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
    LOD 200
    Cull off
    ZWrite On
    ZTest LEqual
    ColorMask RGBA
     
CGPROGRAM
#pragma surface surf Lambert alphatest:_MyCutoff
//alphatest:_Cutoff
 
sampler2D _MainTex;
//fixed _MyCutoff;
struct Input {
    float2 uv_MainTex;
};
 
void surf (Input IN, inout SurfaceOutput o) {
    fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
    fixed4 c = tex;
    o.Albedo = c.rgb;
    o.Alpha = c.a;
//    if (c.a < _MyCutoff )
//    {
//     	o.Alpha = 0;
//    }
}
ENDCG
}
Fallback "Transparent/Cutout/Diffuse"
}