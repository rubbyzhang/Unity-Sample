Shader "Hidden/Glow FX/Glow Blit"
{
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }

    SubShader
    {
        Pass // pass 0 - glow using glow texture
        { 
            name "Glow"
            ZTest Always Cull Off ZWrite Off
            Fog { Mode Off }
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;
            uniform half4 _MainTex_TexelSize;
            uniform float _GlowPower;

            struct v2f
            {
                half4 pos : SV_POSITION;
                half2 uv  : TEXCOORD0;
            };

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.uv = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0) {
                    o.uv.y = 1 - o.uv.y;
                }
            #endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col * _GlowPower * (1-col.a);
            }
            ENDCG
        }

        pass // pass 1 - downsample
        {
            name "SimpleBlur"
            ZTest Always Cull Off ZWrite Off
            Fog { Mode Off }
            Blend Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"

            struct v2f {
                float4 vertex : POSITION;
                float2 uv[4] : TEXCOORD0;
            };

            uniform sampler2D _MainTex;
            uniform half4 _MainTex_TexelSize;

            v2f vert(appdata_img IN) {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.uv[0] = IN.texcoord;
                OUT.uv[1] = IN.texcoord + float2(-0.5, -0.5) * _MainTex_TexelSize.xy;
                OUT.uv[2] = IN.texcoord + float2( 0.5, -0.5) * _MainTex_TexelSize.xy;
                OUT.uv[3] = IN.texcoord + float2(-0.5,  0.5) * _MainTex_TexelSize.xy;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target {
                fixed4 c = 0;
                c += tex2D(_MainTex, IN.uv[0]);
                c += tex2D(_MainTex, IN.uv[1]);
                c += tex2D(_MainTex, IN.uv[2]);
                c += tex2D(_MainTex, IN.uv[3]);
                return c * 0.25;
            }
            ENDCG
        }

        pass // pass2 - Separable Gaussian Blur
        {
            name "GaussBlur"
            ZTest Always Cull Off ZWrite Off
            Fog { Mode Off }
            Blend Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            #include "UnityCG.cginc"

            struct v2f {
                half4 pos : SV_POSITION;
                half4 uv : TEXCOORD0;
                half4 uv01 : TEXCOORD1;
                half4 uv23 : TEXCOORD2;
                half4 uv45 : TEXCOORD3;
                half4 uv67 : TEXCOORD4;
            };

            uniform sampler2D _MainTex;
            uniform half4 _MainTex_TexelSize;
            uniform half4 _BlurSpread;

            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy;
                o.uv01 =  v.texcoord.xyxy + _BlurSpread.xyxy * half4(1,1, -1,-1);
                o.uv23 =  v.texcoord.xyxy + _BlurSpread.xyxy * half4(1,1, -1,-1) * 2.0;
                o.uv45 =  v.texcoord.xyxy + _BlurSpread.xyxy * half4(1,1, -1,-1) * 3.0;
                o.uv67 =  v.texcoord.xyxy + _BlurSpread.xyxy * half4(1,1, -1,-1) * 4.0;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col   = tex2D (_MainTex, i.uv);
                fixed4 color = fixed4(0,0,0,0);
                color += 0.225 * col;
                color += 0.150 * tex2D (_MainTex, i.uv01.xy);
                color += 0.150 * tex2D (_MainTex, i.uv01.zw);
                color += 0.110 * tex2D (_MainTex, i.uv23.xy);
                color += 0.110 * tex2D (_MainTex, i.uv23.zw);
                color += 0.075 * tex2D (_MainTex, i.uv45.xy);
                color += 0.075 * tex2D (_MainTex, i.uv45.zw);
                color += 0.0525 * tex2D (_MainTex, i.uv67.xy);
                color += 0.0525 * tex2D (_MainTex, i.uv67.zw);
                return color;
            }
            ENDCG
        }

        pass // pass 2 - blur the main texture
        {
            name "SimpleBlur"
            ZTest Always Cull Off ZWrite Off
            Fog { Mode Off }
            Blend Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;
            uniform half4 _MainTex_TexelSize;
            uniform half4 _BlurSpread;

            struct v2f {
                half4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                half2 uv1[4] : TEXCOORD1;
            };

            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.uv = v.texcoord;

                o.uv1[0] = v.texcoord + _BlurSpread.xy * half2( 1,  1);
                o.uv1[1] = v.texcoord + _BlurSpread.xy * half2(-1, -1);
                o.uv1[2] = v.texcoord + _BlurSpread.xy * half2( 1, -1);
                o.uv1[3] = v.texcoord + _BlurSpread.xy * half2(-1,  1);
                return o;
            }

            fixed4 frag( v2f i ) : SV_Target
            {
                fixed4 blur = tex2D(_MainTex, i.uv) * 0.4;
                blur += tex2D(_MainTex, i.uv1[0]) * 0.15;
                blur += tex2D(_MainTex, i.uv1[1]) * 0.15;
                blur += tex2D(_MainTex, i.uv1[2]) * 0.15;
                blur += tex2D(_MainTex, i.uv1[3]) * 0.15;
                return blur;
            }
            ENDCG
        }
    }
    Fallback Off

}