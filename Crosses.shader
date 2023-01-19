Shader "pixelspaghetti/Crosses"
{
    Properties
    {
        _Color("Color", Color) = (1.0,1.0,0,1.0)
        _Radius("Radius", Float) = 0.3
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

            struct v2f
            {
                float4 vertex : SV_POSITION;      
                float3 worldPos: TEXCOORD2;
            };
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            
            fixed4 _Color;
            float _Radius;

            float drawCross(float2 pt, float2 center, float radius, float line_width, float edge_thickness){
                float2 p = pt - center;
                float len = length(p);
                float half_line_width = line_width/2.0;
                float result = 0;
                if (len < radius){
                    float horz = smoothstep(-half_line_width-edge_thickness, -half_line_width, p.y) - smoothstep( half_line_width, half_line_width + edge_thickness, p.y);
                    float vert = smoothstep(-half_line_width-edge_thickness, -half_line_width, p.x) - smoothstep( half_line_width, half_line_width + edge_thickness, p.x);
                    result = saturate(horz + vert);
                }
                return result;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 color = _Color;
                float inCross = drawCross(i.worldPos.xz, _Position.xz, _Radius, _Radius*0.1, _Radius*0.01);

                return fixed4(color, 1.0) * inCross;
            }
            ENDCG
        }
    }
}
