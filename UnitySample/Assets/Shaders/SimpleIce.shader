Shader "BlueWar/VFX/SimpleIce"
{
	Properties
	{
        _Color("Color", Color) = (0, 0, 0, 1)
        _MainTex("MainTex", 2D) = "black" {}
		_SnowNormal("SnowNormal", 2D) = "bump" {}
		_SnowShade("SnowShade", 2D) = "white" {}
		_IceCube("IceCube", CUBE) = "white" {}
        // _Opacity("Opacity", Range(-1, 1)) = 0
        _SpikeDirection("Local Space Ice Spike Dir", Vector) = (0, 0, 1, 0)
        _IceThickness("Ice Thickness", Range(0, 0.1)) = 0
        _MaxSpikeLength("Max Spike Length", Range(0, 1)) = 0.02
	}

    SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue"="Geometry+0" }

        LOD 100
		Blend off
		ZWrite on

        CGINCLUDE
        #include "HLSLSupport.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"
        #include "ShadingCommon.cginc"

        uniform fixed4 _Color;
        uniform sampler2D _MainTex;
        uniform sampler2D _SnowShade;
        uniform sampler2D _SnowNormal;
        uniform float4 _SnowNormal_ST;
        // uniform float _Opacity;
        uniform samplerCUBE _IceCube;   
        uniform float4 _SpikeDirection; 
        uniform float _IceThickness;
        uniform float _MaxSpikeLength;

        struct v2f_surf 
        {
            float4 pos     : SV_POSITION;
            float4 pack0   : TEXCOORD0; // _texcoord
            float4 tSpace0 : TEXCOORD1;
            float4 tSpace1 : TEXCOORD2;
            float4 tSpace2 : TEXCOORD3;
            // LIGHTING_COORDS(4, 5)
        };

        inline float rand(float2 coordinate)
        {
            return frac(sin(dot(coordinate, float2(12.9898, 78.233)))*43758.5453);
        }

        // vertex shader
        v2f_surf vert_surf_internal(appdata_full v, v2f_surf o, fixed3 worldNormal)
        {
            v.vertex.xyz = v.vertex.xyz;
            o.pos = UnityObjectToClipPos (v.vertex);
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
            fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
            fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
            o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
            o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
            o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

            // TRANSFER_SHADOW(o);
            return o;
        }

        // fragment shader
        fixed4 frag_surf (v2f_surf IN) : SV_Target 
        {
            float3 worldN;
            float4 tsNormal = tex2D(_SnowNormal, IN.pack0.xy);
            tsNormal.rgb = tsNormal.rgb * 2 - 1;
            worldN.x = dot(IN.tSpace0.xyz, tsNormal.xyz);
            worldN.y = dot(IN.tSpace1.xyz, tsNormal.xyz);
            worldN.z = dot(IN.tSpace2.xyz, tsNormal.xyz);

            float3 worldP = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
            float3 worldL = UnityWorldSpaceLightDir(worldP);
            float3 worldV = normalize(UnityWorldSpaceViewDir(worldP));
            float3 worldR = reflect(-worldV, worldN);
            worldR.z = abs(worldR.z); // hack

            // float shadow = LIGHT_ATTENUATION(IN);
            // float ndl = min(shadow, max(0, dot(worldN, worldL) * 0.5 + 0.5));
            float ndl = max(0.375, dot(worldN, worldL) * 0.5 + 0.5);
            float ndv = max(0, dot(worldN, worldV));
            float4 albedo = tex2D(_SnowShade,float2(ndl, ndv));

            float fresnel = 1.0 - smoothstep(0.9, 1, 1.0 - pow(1.0 - ndv, 5.0)) ;
            albedo.rgb = albedo.rgb * _Color.rgb + 
                lerp(albedo.rgb * min(0.33, ndl) + fresnel * texCUBE(_IceCube, worldR).xyz * _Color.a * 2, 
                tex2D(_SnowShade,float2(ndv, ndl * 0.75)), 1-fresnel);

            // albedo.rgb = lerp(tex2D(_MainTex, IN.pack0.zw).rgb, albedo.rgb, saturate(albedo.a + _Opacity));
            return fixed4(albedo.rgb, 0.5);
        }
        ENDCG

		Pass 
		{

			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }
			Cull Front

			CGPROGRAM
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
            #pragma target 3.0
			#pragma vertex vert_surf
			#pragma fragment frag_surf            

            v2f_surf vert_surf(appdata_full v)
            {
                v2f_surf o;
                UNITY_INITIALIZE_OUTPUT(v2f_surf,o);

                o.pack0.xy = TRANSFORM_TEX(v.texcoord, _SnowNormal);
                o.pack0.zw = v.texcoord.xy;
		        v.vertex.xyz = v.vertex.xyz + -v.normal.xyz * 0.01; 
            
                return vert_surf_internal(v, o, UnityObjectToWorldNormal(-v.normal));
            }
			ENDCG
		}

		Pass 
		{

			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }
			Cull Back

			CGPROGRAM
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
			#pragma target 3.0
			#pragma vertex vert_surf
			#pragma fragment frag_surf          

            uniform float4x4 _RootTransform;

            v2f_surf vert_surf(appdata_full v)
            {
                v2f_surf o;
                UNITY_INITIALIZE_OUTPUT(v2f_surf,o);

                o.pack0.xy = TRANSFORM_TEX(v.texcoord, _SnowNormal);
                o.pack0.zw = v.texcoord.xy;

                _SpikeDirection.xyz = UnityWorldToObjectDir(mul(_RootTransform, float4(normalize(_SpikeDirection.xyz), 0)).xyz);
                
                fixed  random = rand(v.texcoord.xy);
                fixed3 worldN = UnityObjectToWorldNormal(v.normal);
                fixed  factor = smoothstep(0, 0.01, dot(v.normal, _SpikeDirection.xyz));
                v.vertex.xyz = v.vertex.xyz + 
                    v.normal.xyz * lerp(_IceThickness * 0.05f, _IceThickness, factor) + 
                    factor * _MaxSpikeLength * random * step(_SpikeDirection.w, random) * _SpikeDirection.xyz;

                return vert_surf_internal(v, o, worldN);
            }
			ENDCG
		}
    }
    
    FallBack "Diffuse"
}
