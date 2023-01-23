Shader "pixelspaghetti/FunkyRotatingPolygonPattern"
{
    Properties
    {
        _TileCount("Tile Count", Int) = 10
        _Color1("Color 1", Color) = ( 1,0,0,1 )
        _Color2("Color 2", Color) = ( 1,0,0,1 )
        _Radius("Radius", Float) = 0.1
        _DotRadius("Dot Radius", Float) = 0.1
        _OutLineWidth("Outline width", Float) = 0.01
        _Sides("Sides", Int) = 3
        _Rotation("Rotation", Range(0,360)) = 0
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

            #define TAU 6.283185307179586
            #define PI UNITY_PI
            
            int _TileCount;
            fixed4 _Color1;
            fixed4 _Color2;
            float _Radius;
            float _DotRadius;
            float _OutLineWidth;
            float _Sides;
            float _Rotation;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 position: TEXCOORD1;
                float2 uv: TEXCOORD0;
            };
            
            float checkIfDistanceIsInRange(float radius, float distance, float line_width, float edge_thickness){
                float half_line_width = line_width * 0.5;
                return smoothstep(radius - half_line_width - edge_thickness, radius- half_line_width, distance)
                - smoothstep(radius + half_line_width, radius + half_line_width + edge_thickness, distance);
            }

            float2x2 getRotationMatrix(float theta){
                float s = sin(theta);
                float c = cos(theta);

                return float2x2(c,-s,s,c);
            }

            float degreesToRadian(float radians){
                return radians * (PI / 180);
            }

            float drawPolygonOutline(float2 pt, float2 center, float radius, int sides, float rotate, float width, float edge_thickness){
                float2 pointToCheck = pt - center;
                
                //Rotate point by rotation matrix
                float2x2 rotationMatrix = getRotationMatrix(rotate);
                pointToCheck = mul(rotationMatrix, pointToCheck);

                // Angle and radius from the current pixel
                float pointToCheckAngle = atan2( pointToCheck.y, pointToCheck.x );// atan2 returns radians!
                float radiansPerSide = TAU / float( sides );
                float sectorIndex = floor( 0.5 + pointToCheckAngle / radiansPerSide );
                float halfSectorAngle = sectorIndex * radiansPerSide - pointToCheckAngle;

                // Shaping function that modulate the distance
                float distance = cos( halfSectorAngle ) * length( pointToCheck );
                
                return checkIfDistanceIsInRange( radius, distance, width, edge_thickness );
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.position = v.vertex;
                o.uv = v.texcoord;

                float2x2 rotationMatrix = getRotationMatrix(_Time.y * 0.5);
                o.uv =  mul(rotationMatrix, o.uv);  
                
                return o;
            }

            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = frac(i.uv * _TileCount);
                float2 centerPosition = float2( 0,0 ) + 0.5;
                
                fixed3 color = drawPolygonOutline(uv, centerPosition, _Radius * 0.1, _Sides, -_Time.y * 1.9/*degreesToRadian(_Rotation)*/, _OutLineWidth * 0.01, _OutLineWidth * 0.001 );
                color *= lerp(_Color1, _Color2, i.uv.y);
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
