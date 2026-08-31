Shader "Custom/DOSStyleProceduralSkybox" {
    Properties {
        _MainColor ("Space Color", Color) = (0.0, 0.0, 0.1, 1.0)
        _NebulaColor1 ("Nebula Color 1", Color) = (0.7, 0.0, 0.2, 1.0)
        _NebulaColor2 ("Nebula Color 2", Color) = (0.0, 0.2, 0.7, 1.0)
        _NebulaIntensity ("Nebula Intensity", Range(0.0, 2.0)) = 0.6
        _NebulaScale ("Nebula Scale", Range(0.1, 10.0)) = 2.0
        _StarDensity ("Star Density", Range(1.0, 100.0)) = 50.0
        _StarSize ("Star Size", Range(0.1, 5.0)) = 1.0
        _StarTwinkleSpeed ("Star Twinkle Speed", Range(0.0, 10.0)) = 3.0
        _StarTwinkleAmount ("Star Twinkle Amount", Range(0.0, 1.0)) = 0.5
        _PixelationAmount ("Pixelation", Range(1, 512)) = 128.0
        _ColorBanding ("Color Banding", Range(1, 32)) = 16.0
        [Toggle] _EnableTwinkling ("Enable Star Twinkling", Float) = 1
    }
    
    SubShader {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct appdata {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f {
                float4 vertex : SV_POSITION;
                float3 localPos : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            fixed4 _MainColor;
            fixed4 _NebulaColor1;
            fixed4 _NebulaColor2;
            float _NebulaIntensity;
            float _NebulaScale;
            float _StarDensity;
            float _StarSize;
            float _StarTwinkleSpeed;
            float _StarTwinkleAmount;
            float _PixelationAmount;
            float _ColorBanding;
            float _EnableTwinkling;
            
            // Hash function
            float hash(float3 p) {
                p = frac(p * 0.3183099 + 0.1);
                p *= 17.0;
                return frac(p.x * p.y * p.z * (p.x + p.y + p.z));
            }
            
            float hash2(float2 p) {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }
            
            // Simplified noise function
            float noise(float3 x) {
                float3 p = floor(x);
                float3 f = frac(x);
                f = f * f * (3.0 - 2.0 * f);
                
                float n = p.x + p.y * 157.0 + 113.0 * p.z;
                return lerp(
                    lerp(
                        lerp(hash(p + float3(0, 0, 0)), hash(p + float3(1, 0, 0)), f.x),
                        lerp(hash(p + float3(0, 1, 0)), hash(p + float3(1, 1, 0)), f.x),
                        f.y),
                    lerp(
                        lerp(hash(p + float3(0, 0, 1)), hash(p + float3(1, 0, 1)), f.x),
                        lerp(hash(p + float3(0, 1, 1)), hash(p + float3(1, 1, 1)), f.x),
                        f.y),
                    f.z);
            }
            
            v2f vert(appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex.xyz;
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {
                // Direction from center (normalized)
                float3 dir = normalize(i.localPos);
                
                // Apply pixelation to direction
                if (_PixelationAmount > 1) {
                    // Simple pixelation by rounding the direction vector components
                    dir = floor(dir * _PixelationAmount) / _PixelationAmount;
                    dir = normalize(dir); // Re-normalize after pixelation
                }
                
                // Base color
                fixed4 col = _MainColor;
                
                // Nebula effect
                float n1 = noise(dir * _NebulaScale);
                float n2 = noise(dir * _NebulaScale * 2.0 + float3(5.2, 1.3, 2.9));
                float n3 = noise(dir * _NebulaScale * 4.0 + float3(9.1, 7.2, 3.0));
                
                float nebulaMix = n1 * 0.5 + n2 * 0.35 + n3 * 0.15;
                nebulaMix = pow(nebulaMix, 1.5) * _NebulaIntensity;
                
                // Apply nebula colors
                fixed4 nebulaColor = lerp(_NebulaColor1, _NebulaColor2, n2);
                col = lerp(col, nebulaColor, nebulaMix);
                
                // BASIC STAR GENERATION
                // This is a much simpler, more reliable approach
                float stars = 0.0;
                
                // Sample at different densities for different star sizes
                for (int j = 0; j < 3; j++) {
                    float scale = _StarDensity * (1.0 + j * 0.5);
                    float size = _StarSize * (1.0 - j * 0.3);
                    
                    // Get grid position from direction
                    float3 p = dir * scale;
                    
                    // Get nearby grid points
                    float3 grid = floor(p);
                    
                    // Test neighboring cells for potential stars
                    for (int x = -1; x <= 1; x++) {
                        for (int y = -1; y <= 1; y++) {
                            float3 cell = grid + float3(x, y, 0);
                            
                            // Get random value for this cell
                            float cellRand = hash(cell);
                            
                            // Only create stars if random value is high enough
                            if (cellRand > 0.97) {
                                // Get random position within cell
                                float3 cellCenter = cell + 0.5 + (hash(cell + 0.123) - 0.5) * 0.6;
                                
                                // Distance to star center
                                float dist = length(p - cellCenter);
                                
                                // Star brightness - inverse square falloff
                                float brightness = size * 0.015 / (dist * dist * 10.0 + 0.001);
                                
                                // Apply twinkling
                                if (_EnableTwinkling > 0.5) {
                                    float t = _Time.y * _StarTwinkleSpeed;
                                    
                                    // Create multi-frequency twinkling with unique phase offsets
                                    // Use much larger multipliers to ensure each star has its own pattern
                                    float phase1 = cellRand * 328.5;
                                    float phase2 = cellRand * 753.2;
                                    float phase3 = cellRand * 491.7;
                                    
                                    // Combine multiple sine waves at different frequencies
                                    float twinkle = 0.7 
                                                  + 0.15 * sin(t * 1.0 + phase1) 
                                                  + 0.1 * sin(t * 0.7 + phase2) 
                                                  + 0.05 * sin(t * 1.3 + phase3);
                                    
                                    brightness *= twinkle;
                                }
                                
                                // Add star contribution
                                stars = max(stars, brightness);
                            }
                        }
                    }
                }
                
                // Add stars to final color - with slight blue tint
                col.rgb += stars * float3(0.9, 0.95, 1.0);
                
                // Apply color banding for retro look
                col.rgb = floor(col.rgb * _ColorBanding) / _ColorBanding;
                
                return col;
            }
            ENDCG
        }
    }
    
    Fallback Off
}