Shader "pixelspaghetti/Lava"
{
    Properties
    {
        _Scale("Scale", Range(0.1, 3)) = 0.3
        [NoScaleOffset] _MainTex("Main Texture", 2D) = "white" {}
        [NoScaleOffset]  _EmissiveMap("Emissive Map", 2D) = "white" {}
        _EmissionPower("Emission Power", Float) = 1
        _EmissionColor("Emission Color", Color) = (1,1,1,1)
        _TimeMultipler("Time Multipler", Float) = 1
        _DisplacementTex ("Displacement Texture", 2D) = "white" {}
        _MaxDisplacement ("Max Displacement", Float) = 1.0
    }
    SubShader
    {
        Lighting On
        
        // From the Original Shader
        Material
        {
            Emission[_EmissionColor]
        }
        
        Pass{
            SetTexture[_MainTex]{ combine texture }
            SetTexture[_EmissiveMap]{ combine primary lerp(texture) previous }
        }

        LOD 200

        CGPROGRAM

        #pragma surface surf Lambert vertex:vert addshadow

        // https://github.com/ashima/webgl-noise/blob/master/src/
        //https://github.com/NikLever/UnityShaders/tree/master/includes
        #include "noiseSimplex.cginc"

        sampler2D _MainTex;
        sampler2D _EmissiveMap;
        fixed4 _EmissionColor;
        float _EmissionPower;
        sampler2D _DisplacementTex;
        float _MaxDisplacement;

        struct Input {
            float2 uv_MainTex;
            float2 uv_EmissiveMap;
            float4 noise;
        };

        void vert( inout appdata_full v, out Input o)
        {
            // Make lava wavy
            UNITY_INITIALIZE_OUTPUT(Input,o);
            o.noise = 0;

            // get a turbulent 3d noise using the normal, normal to high freq
            o.noise.x = 10.0 *  -0.10 * turbulence( 0.5 * v.normal + _Time.y);

            float4 dispTexColor = tex2Dlod(_DisplacementTex, float4(v.texcoord.xy, 0.0, 0.0));
            float displacement = dot(float3(0.21, 0.72, 0.07), dispTexColor.rgb) * _MaxDisplacement;
            
            // displace vertices along surface normal vector
            float4 newVertexPos = v.vertex + float4(v.normal * displacement * cos(_Time.y) / 5 , 0.0);
            newVertexPos.x = frac(newVertexPos.x  +_Time.y * 0.05); 
            v.vertex = newVertexPos;
        }

        void surf (Input IN, inout SurfaceOutput o) {
            half4 c = tex2D(_MainTex, IN.uv_MainTex);
            half4 e = tex2D(_EmissiveMap, IN.uv_EmissiveMap) * _EmissionColor;
            o.Albedo = c.rgb += e.rgb;

            float fadingEmission = _EmissionPower *= cos(_Time.y * 0.6f) + 1;
            o.Emission = e.rgb * fadingEmission;
        }
        ENDCG
    }
}

