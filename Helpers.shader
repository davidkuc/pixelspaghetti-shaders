
// To convert this into a include file change file extension to .cginc

#define TAU 6.283185307179586

float getDelta( float x ){
    return (sin(x) + 1.0)/2.0;
}

float2x2 getRotationMatrix( float theta ) {
    float s = sin(theta);
    float c = cos(theta);

    return float2x2( c,-s ,s ,c );
}

float degreesToRadian( float radians ) {
    return radians * ( PI / 180 );
}

float radiansToDegrees( float degrees ) {
    return degrees * ( 180 / PI );
}

// not clamped
float lerp( float a, float b, float t) {
    return ( 1.0f - t ) * a + b * t;
}

float invLerp( float a, float b, float v ) {
    return ( v - a ) / ( b - a);
}

float remap( float iMin, float iMax, float oMin, float oMax, float v ) {
    float t = invLerp( iMin, iMax, v );
    return lerp( oMin, oMax, t );  
}
//