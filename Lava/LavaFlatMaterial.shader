// Used on a plane or flat material, has movement + waves

Shader "pixelspaghetti/LavaFlatMaterial"
{
    Properties
    {
        [NoScaleOffset] _MainTex("Main Texture", 2D) = "white" {}
        _TimeInput("Time Input From C#", Float) = 0
        [Header(Emission)]
        [NoScaleOffset]  _EmissiveMap("Emissive Map", 2D) = "white" {}
        _EmissionPower("Emission Power", Float) = 1
        _EmissionColor("Emission Color", Color) = (1,1,1,1)
        [Header(Wave Generation)]
        _GenerateWaves("Generate Waves", Range(0,1)) = 0
        _DisplacementTex ("Displacement Texture", 2D) = "white" {}
        _MaxDisplacement ("Max Displacement", Float) = 1.0
    }
    SubShader
    {
        // Lighting On
        
        // // From the Original Shader
        // Material
        // {
        //     Emission[_EmissionColor]
        // }
        
        // Pass{
        //     SetTexture[_MainTex]{ combine texture }
        //     SetTexture[_EmissiveMap]{ combine primary lerp(texture) previous }
        // }

        // LOD 200

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
        bool _GenerateWaves;
        float _TimeInput;

        struct Input {
            float2 uv_MainTex;
            float2 uv_EmissiveMap;
            float4 noise;
        };

        void vert( inout appdata_full v, out Input o)
        {
            if (_GenerateWaves == 1)
            {
            // Make lava wavy
            UNITY_INITIALIZE_OUTPUT(Input,o);
            o.noise = 0;

            // get a turbulent 3d noise using the normal, normal to high freq
            o.noise.x = 10.0 *  -0.10 * turbulence( 0.5 * v.normal + _Time.y);

            float4 dispTexColor = tex2Dlod(_DisplacementTex, float4(v.texcoord.xy, 0.0, 0.0));
            float displacement = dot(float3(0.21, 0.72, 0.07), dispTexColor.rgb) * _MaxDisplacement;
            
            // displace vertices along surface normal vector
            float4 newVertexPos = v.vertex + float4(v.normal * displacement * (cos(_Time.y) / 12 + 0.3) , 0.0);
             // newVertexPos.x = frac(newVertexPos.x  +_Time.y * 0.05); 
            v.vertex.y = newVertexPos.y;
            }
        }

        void surf (Input IN, inout SurfaceOutput o) {
            float2 uv = float2(IN.uv_MainTex.x + _Time.y * 0.05, IN.uv_MainTex.y);
            half4 c = tex2D(_MainTex, uv);
            half4 e = tex2D(_EmissiveMap, uv) * _EmissionColor;
            o.Albedo = c.rgb += e.rgb;

            //float fadingEmission = _EmissionPower *= cos(_TimeInput * 0.6f) + 1;
            float fadingEmission = _EmissionPower;

            o.Emission = e.rgb * fadingEmission;
        }
        ENDCG
    }
}

