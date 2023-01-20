Shader "MyShaders/Crosshair"
{
    Properties
    {
        _Color("Circle Color", Color) = ( 1,0,0,1 )
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
            
            fixed4 _Color;
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

            float drawPolygon(float2 pt, float2 center, float radius, int sides, float rotate, float edge_thickness){
                pt -= center;

                // Angle and radius from the current pixel
                float theta = atan2(pt.y, pt.x) + rotate;
                float rad = TAU/float(sides);

                // Shaping function that modulate the distance
                float d = cos(floor(0.5 + theta/rad)*rad-theta)*length(pt);

                return 1.0 - smoothstep(radius, radius + edge_thickness, d);
            }

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

            float invLerp( float a, float b, float v ) {
                return ( v - a ) / ( b - a);
            }

            float degreesToRadian(float radians){
                return radians * (PI / 180);
            }

            float radiansToDegrees(float degrees){
                return degrees * (180 / PI);
            }

            float drawCircle(float2 pt, float2 center , float radius, bool soften){
                float2 p = pt - center;
                float edge = (soften) ? radius * 0.01 : 0.0;
                return 1 - smoothstep(radius-edge, radius+edge, length(p));
            }

            float drawCrosshair(float2 pt, float2 center, float radius, int sides, float rotate, float width, float edge_thickness){
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

                if (fmod( sides, 2 ) == 0 && fmod( sectorIndex, 2 ) == 0  ){
                    return 0;
                }

                if (fmod( sides, 3 ) == 0 && fmod( sectorIndex, 3 ) == 0  ){
                    return 0;
                }

                if (fmod( sides, 5 ) == 0 && (sectorIndex == 1 || sectorIndex == -2  )){
                    return 0;
                }

                if (fmod( sides, 7 ) == 0 && (sectorIndex == 1 || sectorIndex == -2 || sectorIndex == 3  )){
                    return 0;
                }
                
                return checkIfDistanceIsInRange( radius, distance, width, edge_thickness );
            }
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.position = v.vertex;
                o.uv = v.texcoord;
                return o;
            }
            
            fixed4 frag ( v2f i ) : SV_Target
            {
                float2 centerPosition = float2( 0,0 ) + 0.5;
                fixed3 color = fixed3( 0,0,0 );
                //color += drawPolygon(i.uv, centerPosition, 0.1, 3, degreesToRadian(_Rotation), 0.001) * _Color; 
                color += drawCrosshair( i.uv, centerPosition, _Radius * 0.1, _Sides, degreesToRadian(_Rotation), _OutLineWidth * 0.01, _OutLineWidth * 0.001 );
                color += drawCircle( i.uv, centerPosition, _DotRadius * 0.1, true );
                //clip(color);
                if ( any(color <= 0) ) {
                    discard;
                }
                return fixed4( color, 1.0 ) ;
            }
            ENDCG
        }
    }
}