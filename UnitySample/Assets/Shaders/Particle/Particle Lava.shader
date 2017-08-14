Shader "Particles/Lava" 
{
    Properties 
     {
        [Header(Properties)]
            _MainTex ("Main Texture (RGB)", 2D) = "white" {}
            _LavaTex ("Shape (R) Noise(B)", 2D) = "black" {} 
            _Speed("Speed", Range(0 , 2)) = 1

        [Header(Render State)]
            [Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 0
            [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 0
            [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendMode ("SrcBlend Mode", Float) = 5
            [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendMode ("DstBlend Mode", Float) = 10
      }

      SubShader
    {
        LOD 100

        Tags
        {
            "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"
        }
        
        Cull [_Cull]
        Lighting Off
        ZWrite [_ZWrite]
        Fog { Mode Off }
        Offset -1, -1
        Blend [_SrcBlendMode] [_DstBlendMode]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityShaderVariables.cginc"
    
            struct appdata_t
            {
                float4 vertex    : POSITION;
                float4 texcoord  : TEXCOORD0;
                fixed4 color     : COLOR; 
            };
    
            struct v2f
            {
                float4 vertex    : SV_POSITION;
                half4  texcoord  : TEXCOORD0;
                fixed4 color     : COLOR;
            };
    
            sampler2D _MainTex;
            sampler2D _LavaTex;
            float4 _MainTex_ST;
            float _Speed;
                
            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.texcoord.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                o.texcoord.zw = v.texcoord.zw;

                return o;
            }
                
            fixed4 frag (v2f i) : COLOR
            {
                fixed4 col = tex2D( _MainTex, i.texcoord.xy );
                col.rgb = ( i.color.rgb * col.rgb );

                float2 uv = float2(0, _Time.y * _Speed);
                uv = i.texcoord.zw + float2(0, (tex2D(_LavaTex, i.texcoord.zw + uv).b * 2 - 1) * 0.1);
                return fixed4( col.rgb, i.color.a * col.a * smoothstep(0.2, 0.5, tex2D(_LavaTex, uv).r) );
            }
            ENDCG
        }
    }
}
