// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "mattatz/ProceduralVolumetricFire" {

    Properties {
        _FireTex ("Fire Texture", 2D) = "white" {}
		_NoiseTex ("Noise Texture", 3D) = "" {}
		_Scale ("Fire Scale", Vector) = (1, 3, 1, 0.5)
		_Lacunarity ("_Lacunarity", float) = 2.0
		_Gain ("_Gain", float) = 0.5
		_Magnitude ("_Magnitude", float) = 1.3
		_Atten ("Attenuation", Range(0.05, 0.7)) = 0.25

		_WavePower ("Wave Power", float) = 0.8
		_WaveSpeed ("Wave Speed", float) = 0.25
		_WaveIntensity ("Wave Intensity", float) = 1.0
		_WaveScale ("Wave Scale", Vector) = (0.25, 1, 0.5)
	}

	SubShader {
		Tags { "RenderType" = "Opaque" }

		LOD 200

		CGINCLUDE

		#include "UnityCG.cginc"

		//#include "./SimplexNoise3D.cginc"

        
float3 mod289(float3 x)
{
    return x - floor(x / 289.0) * 289.0;
}

float4 mod289(float4 x)
{
    return x - floor(x / 289.0) * 289.0;
}

float4 permute(float4 x)
{
    return mod289((x * 34.0 + 1.0) * x);
}

float4 taylorInvSqrt(float4 r)
{
    return 1.79284291400159 - r * 0.85373472095314;
}

float snoise(float3 v)
{
    const float2 C = float2(1.0 / 6.0, 1.0 / 3.0);

    // First corner
    float3 i  = floor(v + dot(v, C.yyy));
    float3 x0 = v   - i + dot(i, C.xxx);

    // Other corners
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 i1 = min(g.xyz, l.zxy);
    float3 i2 = max(g.xyz, l.zxy);

    // x1 = x0 - i1  + 1.0 * C.xxx;
    // x2 = x0 - i2  + 2.0 * C.xxx;
    // x3 = x0 - 1.0 + 3.0 * C.xxx;
    float3 x1 = x0 - i1 + C.xxx;
    float3 x2 = x0 - i2 + C.yyy;
    float3 x3 = x0 - 0.5;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    float4 p =
      permute(permute(permute(i.z + float4(0.0, i1.z, i2.z, 1.0))
                            + i.y + float4(0.0, i1.y, i2.y, 1.0))
                            + i.x + float4(0.0, i1.x, i2.x, 1.0));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float4 j = p - 49.0 * floor(p / 49.0);  // mod(p,7*7)

    float4 x_ = floor(j / 7.0);
    float4 y_ = floor(j - 7.0 * x_);  // mod(j,N)

    float4 x = (x_ * 2.0 + 0.5) / 7.0 - 1.0;
    float4 y = (y_ * 2.0 + 0.5) / 7.0 - 1.0;

    float4 h = 1.0 - abs(x) - abs(y);

    float4 b0 = float4(x.xy, y.xy);
    float4 b1 = float4(x.zw, y.zw);

    //float4 s0 = float4(lessThan(b0, 0.0)) * 2.0 - 1.0;
    //float4 s1 = float4(lessThan(b1, 0.0)) * 2.0 - 1.0;
    float4 s0 = floor(b0) * 2.0 + 1.0;
    float4 s1 = floor(b1) * 2.0 + 1.0;
    float4 sh = -step(h, 0.0);

    float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    float3 g0 = float3(a0.xy, h.x);
    float3 g1 = float3(a0.zw, h.y);
    float3 g2 = float3(a1.xy, h.z);
    float3 g3 = float3(a1.zw, h.w);

    // Normalise gradients
    float4 norm = taylorInvSqrt(float4(dot(g0, g0), dot(g1, g1), dot(g2, g2), dot(g3, g3)));
    g0 *= norm.x;
    g1 *= norm.y;
    g2 *= norm.z;
    g3 *= norm.w;

    // Mix final noise value
    float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    m = m * m;

    float4 px = float4(dot(x0, g0), dot(x1, g1), dot(x2, g2), dot(x3, g3));
    return 42.0 * dot(m, px);
}

		sampler3D _NoiseTex;
		float sample_noise(float3 seed) {
			float n = (tex3D(_NoiseTex, seed).r - 0.5) * 2.0;
			return n;
		}

		// USE PROCEDURAL NOISE
		// #define FIRE_NOISE snoise

		// USE SAMPLING NOISE
		#define FIRE_NOISE sample_noise

        // #include "./ClassicNoise3D.cginc"
        // #define FIRE_NOISE cnoise

        #define FIRE_OCTIVES 4

		fixed _WavePower, _WaveSpeed, _WaveIntensity;
		fixed3 _WaveScale;

        sampler2D _FireTex;
        fixed4 _Scale;
        float _Lacunarity;
        float _Gain;
        float _Magnitude;
        fixed _Atten;

        float turbulence(float3 pos) {
            float sum = 0.0;
            float freq = 1.0;
            float amp = 1.0;

            for(int i = 0; i < FIRE_OCTIVES; i++) {
                sum += abs(FIRE_NOISE(pos * freq)) * amp;
                freq *= _Lacunarity;	
                amp *= _Gain;
            }
            return sum;
        }

        float4 sample_fire (float3 loc, float4 scale) {
            // convert to (radius, height) to sample fire texture.
            float2 st = float2(sqrt(dot(loc.xz, loc.xz)), loc.y);

            // convert loc to noise space
            loc.y -= _Time.y * scale.w;
            loc *= scale.xyz;

            st.y += sqrt(st.y) * _Magnitude * turbulence(loc);

            if(st.y > 1.0) {
                return float4(0, 0, 0, 1);
            }

            return tex2D(_FireTex, st);
        }

        struct v2f {
            float4 pos : POSITION;
            float3 normal : TEXCOORD0;
        };

        v2f vert (appdata_full v) {
            v2f o;

			float y = v.vertex.y; // 0.0 ~ 1.0
			float h = pow(y, _WavePower);
			float n = snoise(v.vertex.xyz * _WaveScale + float3(0, 0, _Time.y * _WaveSpeed));
			v.vertex.x += n * 0.5 * h * _WaveIntensity;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.normal = v.normal;
            return o;
        }

        float4 frag (v2f i) : COLOR {
            // use vertex' normal for tex location.
            float3 loc = i.normal;

            // Range [0.0, 1.0] to [- 1.0, 1.0]
            loc.xz = (loc.xz * 2) - 1.0;

            float4 col = sample_fire(loc, _Scale);
            return float4(col.rgb * _Atten, 1.0);
        }

        ENDCG

        Pass {
            Cull Off
            Blend One One
            ZTest Always

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

    } 

}
