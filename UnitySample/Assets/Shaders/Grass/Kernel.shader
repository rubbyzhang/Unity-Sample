//
// GPGPU kernels for Grass
//
// Position kernel outputs:
// .xyz = position
// .w   = 0
//
// Rotation kernel outputs:
// .xyzw = rotation (quaternion)
//
// Scale kernel outputs:
// .xyz = scale factor
// .w   = random value (0-1)
//
Shader "Hidden/Kvant/Grass/Kernel"
{
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "ClassicNoise3D.cginc"

    float2 _Extent;
    float2 _Scroll;

    float _RandomPitch;
    float3 _RotationNoise;  // freq, amp, time
    float3 _RotationAxis;

    float3 _BaseScale;
    float2 _RandomScale;    // min, max
    float2 _ScaleNoise;     // freq, amp

	sampler2D _PositionTex;
	sampler2D _ForceTex;

	float _GrassDownSpeed;
	float _MaxDownAngle;
	float _RecoverSpeed;
	float _AgentRadius;

	float3 _AgentPos;

    // PRNG function
    float nrand(float2 uv, float salt)
    {
        uv += float2(salt, 0);
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

    // Quaternion multiplication
    // http://mathworld.wolfram.com/Quaternion.html
    float4 qmul(float4 q1, float4 q2)
    {
        return float4(
            q2.xyz * q1.w + q1.xyz * q2.w + cross(q1.xyz, q2.xyz),
            q1.w * q2.w - dot(q1.xyz, q2.xyz)
        );
    }

    // Get the point bound to the UV
    float2 get_point(float2 uv)
    {
        float2 p = float2(nrand(uv, 0), nrand(uv, 1));
        return (p - 0.5) * _Extent;
    }

    float2 get_point_offs(float2 uv, float2 offs)
    {
        float2 p = float2(nrand(uv, 0), nrand(uv, 1));
        return (frac(p + offs) - 0.5) * _Extent;
    }

    // Random rotation around the Y axis
    float4 random_yaw(float2 uv)
    {
        float a = (nrand(uv, 2) - 0.5) * UNITY_PI * 2;
        float sn, cs;
        sincos(a * 0.5, sn, cs);
        return float4(0, sn, 0, cs);
    }

    // Random pitch rotation
    float4 random_pitch(float2 uv)
    {
        float a1 = (nrand(uv, 3) - 0.5) * UNITY_PI * 2;
        float a2 = (nrand(uv, 4) - 0.5) * _RandomPitch * 2;
        float sn1, cs1, sn2, cs2;
        sincos(a1 * 0.5, sn1, cs1);
        sincos(a2 * 0.5, sn2, cs2);
        return float4(float3(cs1, 0, sn1) * sn2, cs2);
    }

    // Pass 0: Position kernel
    float4 frag_position(v2f_img i) : SV_Target
    {
        float2 p = get_point_offs(i.uv, _Scroll);
        return float4((p.x + _Extent.x) / (2 * _Extent.x), 0, (p.y + _Extent.y)/(_Extent.y * 2), 0);
    }

    // Pass 1: Rotation kernel
    float4 frag_rotation(v2f_img i) : SV_Target
    {
        float4 r1 = random_yaw(i.uv);
        float4 r2 = random_pitch(i.uv);

		//r1 = float4(0, 0, 0, 1);
		//r2 = float4(0, 0, 0, 1);

        // Noise to rotation
        float2 np = get_point(i.uv) * _RotationNoise.x;
        float3 nc = float3(np.xy, _RotationNoise.z );

		float4 uv = float4(i.uv, 0, 0);
		float4 f = tex2Dlod(_ForceTex, uv);
		
		f = f * 2 - float4(1, 0, 1, 0);
		f.x = floor((f.x + 0.005) * 100) / 100;
		f.y = floor((f.y + 0.005) * 100) / 100;
		f.z = floor((f.z + 0.005) * 100) / 100;
		f.w = floor((f.w + 0.005) * 100) / 100;
		

		//float nosie = -(cnoise(nc) + 1)/2;
		float nosie = cnoise(nc);
		//nosie = pnoise(nc,float3(1,1,1));
		float na = nosie * _RotationNoise.y;

		//external force
		if (length(f.xyz) > 0)
		{
			na = clamp(length(f) * _MaxDownAngle, 0.0, UNITY_PI / 2);
			float3 up = float3(0, 1, 0);
			_RotationAxis = cross(up, (normalize(f.xyz)));
		}

        // Getting a quaternion of it
        float sn, cs;
        sincos(na * 0.5, sn, cs);
        float4 r3 = float4(_RotationAxis * sn, cs);

		float4 q = qmul(r3, qmul(r2, r1));
		q = (q + float4(1, 1, 1, 1))*0.5f;

		q.x = floor(q.x * 100) / 100;
		q.y = floor(q.y * 100) / 100;
		q.z = floor(q.z * 100) / 100;
		q.w = floor(q.w * 100) / 100;

		return q;

        //return (qmul(r3, qmul(r2, r1)) + float4(1,1,1,1))*0.5f;
    }

	// Pass 1: Rotation kernel
	float4 frag_rotation2(v2f_img i) : SV_Target
	{
		float4 r1 = random_yaw(i.uv);
		float4 r2 = random_pitch(i.uv);

		//r1 = float4(0, 0, 0, 1);
		//r2 = float4(0, 0, 0, 1);

		// Noise to rotation
		float2 np = get_point(i.uv) * _RotationNoise.x;
		float3 nc = float3(np.xy, _RotationNoise.z);

		float4 uv = float4(i.uv, 0, 0);
		float4 f = tex2Dlod(_ForceTex, uv);

		f = f * 2 - float4(1, 0, 1, 0);
		f.x = floor((f.x + 0.005) * 100) / 100;
		f.y = floor((f.y + 0.005) * 100) / 100;
		f.z = floor((f.z + 0.005) * 100) / 100;
		f.w = floor((f.w + 0.005) * 100) / 100;

		//float nosie = -(cnoise(nc) + 1)/2;
		float nosie = cnoise(nc);
		//nosie = pnoise(nc,float3(1,1,1));
		float na = nosie * _RotationNoise.y;

		//external force
		if (length(f.xyz) > 0)
		{
			na = clamp(length(f) * _MaxDownAngle, 0.0, UNITY_PI / 2);
			float3 up = float3(0, 1, 0);
			_RotationAxis = cross(up, (normalize(f.xyz)));
		}

		// Getting a quaternion of it
		float sn, cs;
		sincos(na * 0.5, sn, cs);
		float4 r3 = float4(_RotationAxis * sn, cs);

		float4 q = qmul(r3, qmul(r2, r1));
		q = (q + float4(1, 1, 1, 1))*0.5f;

		q.x = floor((q.x - floor(q.x * 100) / 100) * 10000) / 100;
		q.y = floor((q.y - floor(q.y * 100) / 100) * 10000) / 100;
		q.z = floor((q.z - floor(q.z * 100) / 100) * 10000) / 100;
		q.w = floor((q.w - floor(q.w * 100) / 100) * 10000) / 100;

		return q;
	}

    // Pass 2: Scale kernel
    float4 frag_scale(v2f_img i) : SV_Target
    {
        // Random scale factor
        float s1 = lerp(_RandomScale.x, _RandomScale.y, nrand(i.uv, 5));

        // Noise to scale factor
        float2 np = get_point(i.uv) * _ScaleNoise.x;
        float3 nc = float3(np.xy, 0.92 /* magic num */);
        float s2 = cnoise(nc) * _ScaleNoise.y;

		float4 scale = float4(_BaseScale * (s1 + s2), nrand(i.uv, 6));

        return float4(scale.xyz / 5,scale.w);
    }

	float4 frag_force(v2f_img i) : SV_Target
	{
		float4 uv = float4(i.uv, 0, 0);
		float4 p = tex2Dlod(_PositionTex, uv);
		float4 f = tex2Dlod(_ForceTex, uv);

		f.xyz = f.xyz * 2 - float3(1, 0, 1);
		f.x = floor((f.x + 0.005) * 100) / 100;
		f.y = floor((f.y + 0.005) * 100) / 100;
		f.z = floor((f.z + 0.005) * 100) / 100;
		f.w = floor((f.w + 0.005) * 100) / 100;
		

		float4 nf = float4(0,0,0,0);

		float3 dir = float3(p.x * _Extent.x * 2 - _Extent.x, 0, p.z * _Extent.y * 2 - _Extent.y) - _AgentPos;
		if (length(dir) < _AgentRadius)
		{
			nf = f + float4(_GrassDownSpeed*normalize(dir),0);
			if (length(nf) >= 1)
			{
				nf = float4(normalize(nf.xyz), 0);
			}
		}
		else
		{
			if (length(f.xyz) > 0)
			{
				float curFM = clamp(length(f.xyz) - _RecoverSpeed,0.0,1.0);
				nf = float4(normalize(f.xyz)*curFM, 0);
			}
		}

		nf.x = floor(nf.x * 100) / 100;
		nf.y = floor(nf.y * 100) / 100;
		nf.z = floor(nf.z * 100) / 100;
		nf.w = floor(nf.w * 100) / 100;
		nf.xyz = (nf.xyz + float3(1, 0, 1)) * 0.5f;

		return nf;
	}

    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag_position
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag_rotation
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag_scale
            ENDCG
        }
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment frag_force
			ENDCG
		}
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment frag_rotation2
			ENDCG
		}
    }
}
