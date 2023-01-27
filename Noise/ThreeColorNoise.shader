Shader "pixelspaghetti/ThreeColorNoise"
{
    Properties
    {
        _Color1("Color 1", Color) = (0.49, 0.286, 0.043, 1)
        _Color2("Color 2", Color) = (0.733, 0.565, 0.365, 1)
        _Color3("Color 3", Color) = (0.733, 0.565, 0.365, 1)
        _Frequency("Frequency", Float) = 2.0
        _NoiseScale("Noise Scale", Float) = 6.0
        _RingScale("Ring Scale", Float) = 0.6
        _Contrast("Contrast", Float) = 4.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "noiseSimplex.cginc"

            fixed4 _Color1;
            fixed4 _Color2;
            fixed4 _Color3;
            float _Frequency;
            float _NoiseScale;
            float _RingScale;
            float _Contrast;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 position: TEXCOORD1;
            };

            float checkIfIsInRange(float min, float max, float value)
            {
                return min <= value <= max;
            }
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.position = v.vertex;
                return o;
            }

            float4 frag (v2f i) : COLOR
            {
                float3 pos = i.position.xyz * 2.0 + _Time.y;
                float n = snoise( pos );
                float ring = frac( _Frequency * pos.z + _NoiseScale * n );
                ring *= _Contrast * ( 1.0 - ring );

                // Adjust ring smoothness and shape, and add some noise
                float delta = pow( ring, _RingScale ) + n;

                fixed3 color = ( checkIfIsInRange(0.008,0.01,delta) * _Color1) +( checkIfIsInRange(0.1,0.28,delta) * _Color2) + ( checkIfIsInRange(0.3,0.32,delta) * _Color3);

                return fixed4( color, 1.0 );
            }
            ENDCG
        }
    }
}
