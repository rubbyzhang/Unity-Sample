Shader "BlueWar/VFX/Petrify"
{
    Properties
    {
        [Header(Shader Properties)]
            _Color("Color(RGB) Stone(A)", Color) = (0.3, 0.3, 0.3, 1)
            _MainTex ("Albedo Texture", 2D) = "white" {}
            _RockTex ("Rock Texture", 2D) = "white" {}
            _RampTex ("Ramp Texture", 2D) = "black" {}
            _RampFactor("Ramp Factor", Range(4, 64)) = 24

        [Header(Render State)]
            [Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 0
            [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent+1" }

        LOD 100

        Offset -1, -1 Cull [_Cull] ZTest LEqual  ZWrite [_ZWrite]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "ShadingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex; float4 _MainTex_ST;
            sampler2D _RockTex; float4 _RockTex_ST;
            sampler2D _RampTex; float4 _RampTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy  = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw  = TRANSFORM_TEX(v.uv, _RockTex);
                o.uv1.xy = TRANSFORM_TEX(v.uv, _RampTex);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                return o;
            }

            fixed4 _Color;
            fixed  _RampFactor;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 dissolve = float2((_Color.a * 1.2 - 0.6) + tex2D(_RockTex, i.uv1.xy).a, 0);
                dissolve.y = (1.0 - saturate(dissolve.x * _RampFactor - _RampFactor * 0.5));
                clip(dissolve.x - 0.5);

                // sample the texture
                fixed4 rock = tex2D(_RockTex, i.uv.zw);
                fixed4 base = tex2D(_MainTex, i.uv.xy);

                fixed3 result = (max(0, dot(CHARACTER_SUNLIGHTDIR.xyz, i.normal.xyz) * 0.5 + 0.5) * _Color.rgb + CharacterAmbientLightColor.rgb) * (rock.r + Luminance(base) * 0.4);
                result += ( dissolve.y * tex2D(_RampTex, float2( dissolve.y, 1)) ).xyz;
                return fixed4(result, 1);
            }
            ENDCG
        }
    }
}
