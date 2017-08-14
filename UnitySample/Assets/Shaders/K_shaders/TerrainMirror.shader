Shader "KTA/TerrainMirror" {
Properties {
 
    // Control Texture ("Splat Map")
    [HideInInspector] _Control ("Control (RGBA)", 2D) = "red" {}
     
    // Terrain textures - each weighted according to the corresponding colour
    // channel in the control texture
    [HideInInspector] _Splat3 ("Layer 3 (A)", 2D) = "white" {}
    [HideInInspector] _Splat2 ("Layer 2 (B)", 2D) = "white" {}
    [HideInInspector] _Splat1 ("Layer 1 (G)", 2D) = "white" {}
    [HideInInspector] _Splat0 ("Layer 0 (R)", 2D) = "white" {}
     
    // Used in fallback on old cards & also for distant base map
    [HideInInspector] _MainTex ("BaseMap (RGB)", 2D) = "white" {}
    [HideInInspector] _Color ("Main Color", Color) = (1,1,1,1)
    
	_LightMap ("LightMap", 2D) = "gray" {}   
	
	_TerrainWidth  ("TerrainWidth", Float) = 0   
}
     
SubShader {
    Tags {
        "SplatCount" = "4"
        "Queue" = "Geometry-2"
        "RenderType" = "Opaque"
        "IgnoreProjector"="True"
    }
    
    Lighting Off
    Cull Off
     
    // TERRAIN PASS 
    CGPROGRAM
    #pragma surface surf NoLight vertex:vert
    #pragma multi_compile TERRAIN_QUALITY_HIGH TERRAIN_QUALITY_LOW
 
    // Access the Shaderlab properties
#ifdef TERRAIN_QUALITY_HIGH
    uniform sampler2D _Control;
    uniform sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
#else
    uniform sampler2D _MainTex;
#endif
    //uniform fixed4 _Color;
    sampler2D _LightMap;
    float _TerrainWidth;
 
    // Surface shader input structure
    struct Input {
        float2 uv_Control : TEXCOORD0;
#ifdef TERRAIN_QUALITY_HIGH
        float2 uv_Splat0 : TEXCOORD1;
        float2 uv_Splat1 : TEXCOORD2;
        float2 uv_Splat2 : TEXCOORD3;
        float2 uv_Splat3 : TEXCOORD4;
#endif
    };
    
 	half4 LightingNoLight (SurfaceOutput s, half3 lightDir, half atten) {
              //half4 c;
              //c.rgb = s.Albedo;
              //c.a = 0;
              //return c;
              return fixed4(0,0,0,0);
          }    
          
  	void vert (inout appdata_full v) {
  	    	v.vertex.x = _TerrainWidth - v.vertex.x;
  	    	
          	//v.vertex.z = - v.vertex.z;
      }
 
    // Surface Shader function
    void surf (Input IN, inout SurfaceOutput o) {
#ifdef TERRAIN_QUALITY_HIGH
        fixed4 splat_control = tex2D (_Control, IN.uv_Control);
        fixed3 col;
        col  = splat_control.r * tex2D (_Splat0, IN.uv_Splat0).rgb;
        col += splat_control.g * tex2D (_Splat1, IN.uv_Splat1).rgb;
        col += splat_control.b * tex2D (_Splat2, IN.uv_Splat2).rgb;
        col += splat_control.a * tex2D (_Splat3, IN.uv_Splat3).rgb;
#else  
        fixed3 col = tex2D (_MainTex, IN.uv_Control);
#endif
        
        o.Albedo = col;// * _Color;
        
		fixed4 lm = tex2D (_LightMap, IN.uv_Control);
		col = col + col * 2 * (lm.rgb-fixed3(0.5,0.5,0.5));	
		//o.Albedo *= _Color;
		
		o.Emission = col;
		o.Albedo *= 0.0; 
        
        
        o.Alpha = 0.0;
    }
    ENDCG
} // End SubShader
 
// Fallback to Diffuse
Fallback "Diffuse"
 
} // Ehd Shader