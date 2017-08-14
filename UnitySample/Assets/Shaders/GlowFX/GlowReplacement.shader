Shader "Hidden/Glow FX/Glow Replacement"
 {
    CGINCLUDE
    #include "UnityCG.cginc"

    uniform sampler2D _CameraDepthTexture;

    struct v2f
    {
        float4 pos  : SV_POSITION;
        half2  uv   : TEXCOORD0;
        float4 hpos : TEXCOORD1;
    };

    v2f vert(appdata_img v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos (v.vertex);
        o.uv = v.texcoord;
        o.hpos = ComputeScreenPos(o.pos);
        COMPUTE_EYEDEPTH(o.hpos.z);
        return o;
    }
    ENDCG

    SubShader
    {
        Tags { "GlowType" = "Transparent" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            uniform sampler2D _MainTex;

            fixed4 frag(v2f i) : SV_Target
            {
                float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.hpos)));
                clip(sceneZ - i.hpos.z);

                return tex2D(_MainTex,i.uv);
            }
            ENDCG
        }
    }

    SubShader
    {
        Tags { "GlowType" = "Opaque" }
        ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            uniform sampler2D _MainTex;

            fixed4 frag(v2f i) : SV_Target
            {
                float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.hpos)));
                clip(sceneZ - i.hpos.z);

                return tex2D(_MainTex,i.uv);
            }
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType" = "TransparentCutout" }
        ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            uniform sampler2D _MainTex;
            uniform float _Cutoff;

            fixed4 frag(v2f i) : SV_Target
            {
                float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.hpos)));
                clip(sceneZ - i.hpos.z);

                fixed4 col = tex2D(_MainTex,i.uv);
                clip (col.a - _Cutoff);
                return col;
            }
            ENDCG
        }
    }
    Fallback Off
}
