Shader "MyShaders/CircleHighlight"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Radius("Radius", Range(0, 3)) = 1
        _Position("Position", Vector) = (0,0,0,0)
        _CircleColor("Circle Color", Color) = ( 1,0,0,1 )
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

            sampler2D _MainTex;
            float4 _Position;
            fixed4 _CircleColor;
            float _Radius;

            struct v2f
            {
                float4 vertex : SV_POSITION;      
                float3 worldPos: TEXCOORD2;
            };

            float circle(float2 pt, float2 center, float radius, float line_width, float edge_thickness){
                float2 p = pt - center;
                float len = length(p);
                float half_line_width = line_width/2.0;
                float result = smoothstep(radius-half_line_width-edge_thickness, radius-half_line_width, len)
                - smoothstep(radius + half_line_width, radius + half_line_width + edge_thickness, len);

                return result;
            }
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul (unity_ObjectToWorld, v.vertex);
                return o;
            }
            
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 color = _CircleColor;
                float inCircle = circle(i.worldPos.xz, _Position.xz, _Radius, _Radius*0.1, _Radius*0.01);

                return fixed4(color, 1.0) * inCircle;
            }
            ENDCG
        }
    }
}