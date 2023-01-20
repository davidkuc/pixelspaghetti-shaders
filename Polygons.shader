Shader "pixelspaghetti/Polygons"
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

            float checkIfDistanceIsInRange(float radius, float distance, float line_width, float edge_thickness){
                float half_line_width = line_width * 0.5;
                return smoothstep(radius - half_line_width - edge_thickness, radius- half_line_width, distance)
                - smoothstep(radius + half_line_width, radius + half_line_width + edge_thickness, distance);
            }

            float drawPolygon(float2 pt, float2 center, float radius, int sides, float rotate, float edge_thickness){
                pt -= center;

                // Angle and radius from the current pixel
                float theta = atan2(pt.y, pt.x) + rotate;
                float rad = PI2/float(sides);

                // Shaping function that modulate the distance
                float d = cos(floor(0.5 + theta/rad)*rad-theta)*length(pt);

                return 1.0 - smoothstep(radius, radius + edge_thickness, d);
            }

            float drawPolygonOutline(float2 pt, float2 center, float radius, int sides, float rotate, float width, float edge_thickness){
                float2 pointToCheck = pt - center;
                
                //Rotate point by rotation matrix
                float2x2 rotationMatrix = getRotationMatrix(rotate);
                pointToCheck = mul(rotationMatrix, pointToCheck);

                // Angle and radius from the current pixel
                float pointToCheckAngle = atan2( pointToCheck.y, pointToCheck.x ); // atan2 returns radians!
                float radiansPerSide = TAU / float( sides );
                float sectorIndex = floor( 0.5 + pointToCheckAngle / radiansPerSide );
                float halfSectorAngle = sectorIndex * radiansPerSide - pointToCheckAngle;

                // Shaping function that modulate the distance
                float distance = cos( halfSectorAngle ) * length( pointToCheck );
                
                return checkIfDistanceIsInRange( radius, distance, width, edge_thickness );
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
