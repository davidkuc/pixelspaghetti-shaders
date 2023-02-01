// Cool emission with funny curvature thingy that changes how the object displays depending on camera angle
Shader "pixelspaghetti/Emission"
{
    Properties{
        _MainTex("Base (RGB)", 2D) = "white" {}
        
        _EmissiveMap("Emissive Map", 2D) = "white" {}
        _EmissionPower("Emission Power", Float) = 1
        _EmissionColor("Emission Color", Color) = (1,1,1,1)
        
        // Degree of curvature
        _Curvature("Curvature", Float) = 0.001
    }
    
    SubShader{
        Lighting On
        
        // From the Original Shader
        Material
        {
            Emission[_EmissionColor]
        }
        
        Pass{
            SetTexture[_MainTex]{ combine texture }
            SetTexture[_EmissiveMap]{ combine primary lerp(texture) previous }
        }
        // End of Original Shader
        
        LOD 200
        
        // New Shader
        
        CGPROGRAM
        // Surface shader function is called surf, and vertex preprocessor function is called vert
        // addshadow used to add shadow collector and caster passes following vertex modification
        #pragma surface surf Lambert vertex:vert addshadow
        
        // Access the shaderlab properties
        sampler2D _MainTex;
        sampler2D _EmissiveMap;
        fixed4 _EmissionColor;
        float _EmissionPower;
        float _Curvature;
        
        // Basic input structure to the shader function
        // requires only a single set of UV texture mapping coordinates
        struct Input {
            float2 uv_MainTex;
            float2 uv_EmissiveMap;
        };
        
        // This is where the curvature is applied
        void vert( inout appdata_full v)
        {
            // Transform the vertex coordinates from model space into world space
            float4 vv = mul( unity_ObjectToWorld, v.vertex );
            
            // Now adjust the coordinates to be relative to the camera position
            vv.xyz -= _WorldSpaceCameraPos.xyz;
            
            // Reduce the y coordinate (i.e. lower the "height") of each vertex based
            // on the square of the distance from the camera in the z axis, multiplied
            // by the chosen curvature factor
            vv = float4(0.0f, (vv.z * vv.z) * - _Curvature, 0.0f, 0.0f );
            
            // Now apply the offset back to the vertices in model space
            v.vertex += mul(unity_WorldToObject, vv);
        }
        
        // This is just a default surface shader
        void surf (Input IN, inout SurfaceOutput o) {
            half4 c = tex2D(_MainTex, IN.uv_MainTex);
            half4 e = tex2D(_EmissiveMap, IN.uv_EmissiveMap) * _EmissionColor;
            o.Albedo = c.rgb += e.rgb;
            o.Emission = e.rgb * _EmissionPower;
        }
        ENDCG
    }
}
