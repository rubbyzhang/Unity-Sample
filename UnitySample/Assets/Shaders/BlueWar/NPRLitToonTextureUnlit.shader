Shader "BlueWar/NPRLitToonTextureUnlit" 
{
    Properties 
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }

    CGINCLUDE
    struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	v2f NPRToonOpaqueReflectionVS(float4 vertex : POSITION, float2 texcoord : TEXCOORD0) 
	{
		v2f o;
		UNITY_INITIALIZE_OUTPUT(v2f, o);
		o.pos = UnityObjectToClipPos(vertex);
		o.uv.xy = texcoord.xy;
		return o;
	}

	sampler2D _MainTex;

	fixed4 NPRToonOpaqueReflectionPS(v2f IN): SV_Target 
	{
		return tex2D(_MainTex, IN.uv.xy);
	}
    ENDCG

    // for reflection
    SubShader 
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "ForceNoShadowCasting" = "True" }

        LOD 50

        Pass 
        {
            Tags { "LightMode" = "Always" }

            Cull Back ZTest LEqual

            CGPROGRAM
            #pragma vertex   NPRToonOpaqueReflectionVS
            #pragma fragment NPRToonOpaqueReflectionPS
            ENDCG
        }
    }

    SubShader 
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "ForceNoShadowCasting" = "True" }

        LOD 50

        Pass 
        {
            Tags { "LightMode" = "Always" }

            Cull Back ZTest LEqual Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex   NPRToonOpaqueReflectionVS
            #pragma fragment NPRToonOpaqueReflectionPS
            ENDCG
        }
    }    

	 SubShader 
    {
        Tags { "RenderType" = "TransparentCutout" "Queue" = "Transparent" "ForceNoShadowCasting" = "True" }

        LOD 50

        Pass 
        {
            Tags { "LightMode" = "Always" }

            Cull Back ZTest LEqual Blend Off

            CGPROGRAM
            #pragma vertex   NPRToonOpaqueReflectionVS
            #pragma fragment NPRToonOpaqueReflectionPS
            ENDCG
        }
    }    
}