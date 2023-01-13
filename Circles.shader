Shader "pixelspaghetti/Circles"
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
                float4 position : TEXCOORD1;
                float2 uv: TEXCOORD0;
            };
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.position = v.vertex;
                o.uv = v.texcoord;
                return o;
            }
            
            fixed4 _Color;
            float _Radius;

            // no soften
            float circle(float2 pt, float2 center , float radius){
                float2 p = pt - center;
                return 1 - step(radius, length(p));
            }

            // softened
            float circle(float2 pt, float2 center , float radius, bool soften){
                float2 p = pt - center;
                float edge = (soften) ? radius * 0.01 : 0.0;
                return 1 - smoothstep(radius-edge, radius+edge, length(p));
            }

            // not softened
            float circleOutline(float2 pt, float2 center , float radius, float line_width){
                float2 p = pt - center;
                float len = length(p);
                float half_line_width = line_width/2;
                return step(radius-half_line_width, len) - step(radius + half_line_width, len);
            }

            // Soften inside only
            float circleOutline(float2 pt, float2 center , float radius, float line_width, float edge_thickness){
                float2 p = pt - center;
                float len = length(p);
                float half_line_width = line_width/2;
                return smoothstep(radius - half_line_width - edge_thickness,radius - half_line_width, len) 
                - smoothstep(radius + half_line_width + edge_thickness, radius + half_line_width + edge_thickness, len);
            }

            // filled in circle + outline + soften
            float circleWithOutline(float2 pt, float2 center , float radius, float line_width, float edge_thickness, bool soften){
                float2 p = pt - center;
                float len = length(p);
                float half_line_width = line_width/2;
                float fill = Circle(pt, center, radius + half_line_width + edge_thickness, soften);
                return smoothstep(radius - half_line_width - edge_thickness,radius - half_line_width, len) 
                - smoothstep(radius + half_line_width, radius + half_line_width + edge_thickness, len)
                + fill;
            }

            // outline + soften on both sides
            float circleOutline(float2 pt, float2 center , float radius, float line_width, float edge_thickness, bool soften){
                float2 p = pt - center;
                float len = length(p);
                float half_line_width = line_width/2;
                float edge = (soften) ? radius * 0.01 : 0.0;
                return smoothstep(radius - half_line_width - edge_thickness,radius - half_line_width, len) 
                - smoothstep(radius + half_line_width, radius + half_line_width + edge_thickness, len);
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 pos = i.position * 2;
                fixed3 color = _Color * Circle(pos, float2(0,0), _Radius);
                //fixed3 color = _Color * Circle(pos, float2(0,0), _Radius, true);
                //fixed3 color = _Color * circleWithOutline(pos, float2(0,0), _Radius, 0.05, 0.01, true);
                //fixed3 color = _Color * circleOutline(pos, float2(0,0), _Radius, 0.05, 0.01);
                //fixed3 color = _Color * CircleOutline(pos, float2(0,0), _Radius, 0.05, 0.01, true);
                //   fixed3 color = _Color * Circle(pos, float2(0,0), _Radius, 0.05);
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
