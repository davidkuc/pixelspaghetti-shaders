Shader "pixelspaghetti/Lines"
{
    Properties
    {
        _Color("Color", Color) = (1.0,1.0,1.0,1.0)
        _LineWidth("Line Width", Float) = 0.01
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
                float2 uv: TEXCOORD0;
                float4 position: TEXCOORD1;
                float4 screenPos: TEXCOORD2;
            };
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.position = v.vertex;
                o.uv = v.texcoord;
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }
            
            fixed4 _Color;
            float _LineWidth;
            
            float getDelta( float x ){
                return (sin(x) + 1.0)/2.0;
            }

            // Checks if point is on line
            float checkIfPointIsOnLine(float a, float b, float line_width, float edge_thickness){
                float half_line_width = line_width * 0.5;
                return smoothstep(a - half_line_width - edge_thickness, a - half_line_width, b)
                - smoothstep(a + half_line_width, a + half_line_width + edge_thickness, b);
            }

            fixed4 drawLine(float a, float b, float4 inputColor, float line_width, float edge_width) {
                fixed3 color = lerp(fixed3(0,0,0), inputColor.rgb, checkIfPointIsOnLine(a, b, line_width, edge_width * 0.1)); 
                return fixed4(color, 1);
            }

            fixed4 drawSinLine(float x, float y, float4 inputColor, float line_width, float edge_width) {
                fixed3 color = inputColor * checkIfPointIsOnLine(y, lerp(-0.4, 0.4, getDelta(x * UNITY_TWO_PI)) + 0.5, line_width, edge_width); 
                return fixed4(color, 1);
            }

            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 pos = i.position.xy * 2;
                // Diagonal ine
                //float2 uv = i.screenPos.xy / i.screenPos.w;
                //fixed3 color = lerp(fixed3(0,0,0), _Color.rgb, checkIfPointIsOnLine(uv.x, uv.y, _LineWidth, _LineWidth * 0.1)); 

                // Sin line
                //float2 uv = i.uv;
                //fixed3 color = _Color * checkIfPointIsOnLine(pos.y, sin(pos.x * UNITY_PI), 0.05, 0.002); 

                // Sin line - more adjustable
                //float2 uv = i.uv;
                //fixed3 color = _Color * checkIfPointIsOnLine(uv.y, lerp(-0.4, 0.4, getDelta(uv.x * UNITY_TWO_PI * 3)) + 0.5, _LineWidth, 0.002); 

                fixed3 color = drawLine(uv.y, uv.x, _Color, _LineWidth, _LineWidth * 0.1);
                //fixed3 color = drawSinLine(uv.y, uv.x, _LineWidth, _LineWidth * 0.1);

                // fixed3 color = checkIfPointIsOnLine(i.uv.y, , 0.5, 0.002, 0.001) * _AxisColor;
                
                //return fixed4(color, 1.0);
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
