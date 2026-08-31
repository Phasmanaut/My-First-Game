Shader "Custom/DOSStylePlanetSkySkybox" {
    Properties {
        _SkyColor ("Sky Color", Color) = (0.4, 0.6, 0.9, 1.0)
        _HorizonColor ("Horizon Color", Color) = (0.7, 0.8, 0.9, 1.0)
        _HorizonSharpness ("Horizon Sharpness", Range(1.0, 20.0)) = 4.0
        
        [Header(Clouds)]
        _CloudColor ("Cloud Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _CloudDensity ("Cloud Density", Range(0.0, 2.0)) = 0.8
        _CloudCoverage ("Cloud Coverage", Range(0.0, 1.0)) = 0.5
        _CloudSpeed ("Cloud Speed", Range(0.0, 2.0)) = 0.2
        _CloudScale ("Cloud Scale", Range(0.1, 10.0)) = 2.0
        _CloudLayers ("Cloud Layers", Range(1, 3)) = 2
        _CloudHorizonOnly ("Cloud Horizon Only", Range(0.0, 1.0)) = 0.8
        _CloudMaxHeight ("Cloud Max Height", Range(0.0, 1.0)) = 0.4
        
        [Header(DOS Style Effects)]
        _PixelationAmount ("Pixelation", Range(1, 512)) = 128.0
        _ColorBanding ("Color Banding", Range(1, 32)) = 16.0
        [Toggle] _DitherEffect ("Enable Dithering", Float) = 1
        _DitherAmount ("Dither Amount", Range(0.0, 1.0)) = 0.05
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
            
            fixed4 _SkyColor;
            fixed4 _HorizonColor;
            float _HorizonSharpness;
            
            fixed4 _CloudColor;
            float _CloudDensity;
            float _CloudCoverage;
            float _CloudSpeed;
            float _CloudScale;
            int _CloudLayers;
            float _CloudHorizonOnly;
            float _CloudMaxHeight;
            
            float _PixelationAmount;
            float _ColorBanding;
            float _DitherEffect;
            float _DitherAmount;
            
            // Hash function for randomization
            float hash(float3 p) {
                p = frac(p * 0.3183099 + 0.1);
                p *= 17.0;
                return frac(p.x * p.y * p.z * (p.x + p.y + p.z));
            }
            
            float hash2(float2 p) {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }
            
            // Simplified noise function for clouds
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
            
            // Ordered dithering matrix (Bayer 4x4)
            static const float ditherPattern[16] = {
                0.0/16.0, 8.0/16.0, 2.0/16.0, 10.0/16.0,
                12.0/16.0, 4.0/16.0, 14.0/16.0, 6.0/16.0,
                3.0/16.0, 11.0/16.0, 1.0/16.0, 9.0/16.0,
                15.0/16.0, 7.0/16.0, 13.0/16.0, 5.0/16.0
            };
            
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
                
                // Calculate sky gradient based on up direction (y-axis)
                float skyGradient = pow(max(0.0, dir.y), _HorizonSharpness);
                
                // Base sky color with horizon gradient
                fixed4 col = lerp(_HorizonColor, _SkyColor, skyGradient);
                
                // Skip clouds below horizon to create ground effect
                if (dir.y > 0.0) {
                    // Cloud height mask - only show clouds near horizon, fade out as we look up
                    // This creates the effect of clouds only at the horizon
                    float cloudHeightMask = 1.0 - smoothstep(0.0, _CloudMaxHeight, dir.y);
                    
                    // Only proceed with cloud calculation if we're in the cloud height zone
                    if (cloudHeightMask > 0.01) {
                        // Cloud generation
                        float cloudVal = 0.0;
                        
                        // Create multiple layers of clouds with different speeds
                        for (int j = 0; j < _CloudLayers; j++) {
                            // Create cloud movement along the x-z plane
                            float speed = _CloudSpeed * (1.0 + j * 0.5);
                            float scale = _CloudScale * (1.0 - j * 0.3);
                            
                            // Use hemisphere projection for more natural cloud distribution
                            float2 cloudCoord = float2(dir.x, dir.z) / (1.0 - dir.y * 0.8);
                            
                            // Vary speed based on layer
                            float2 layerOffset = _Time.y * speed * float2(0.4, 0.6);
                            if (j == 1) layerOffset = _Time.y * speed * float2(0.5, 0.3);
                            if (j == 2) layerOffset = _Time.y * speed * float2(0.6, 0.5);
                            
                            // Apply offset to coordinates
                            float2 animatedCoord = cloudCoord + layerOffset;
                            
                            // Sample multiple noise octaves for more natural clouds
                            float n1 = noise(float3(animatedCoord * scale, j * 8.7));
                            float n2 = noise(float3(animatedCoord * scale * 2.1, j * 8.7 + 13.4));
                            float n3 = noise(float3(animatedCoord * scale * 4.3, j * 8.7 + 7.2));
                            
                            // Combine noise with different weights for more varied shapes
                            float cloudNoise = n1 * 0.5 + n2 * 0.35 + n3 * 0.15;
                            
                            // Apply coverage with varying thresholds for more natural transition
                            float edgeSoftness = 0.3 + j * 0.1; // Vary softness per layer
                            cloudNoise = smoothstep(_CloudCoverage - edgeSoftness, _CloudCoverage + edgeSoftness, cloudNoise);
                            
                            // Apply height-based intensity
                            // The horizon-only effect is applied here
                            float heightFactor = _CloudHorizonOnly > 0.01 ? 
                                                 (1.0 - pow(dir.y / _CloudMaxHeight, 2.0)) : 
                                                 1.0;
                            
                            // Layer thickness decreases with height
                            float layerWeight = 1.0 - (j * 0.3);
                            
                            // Apply height mask and accumulate cloud value
                            cloudNoise *= heightFactor * layerWeight;
                            cloudVal = max(cloudVal, cloudNoise);
                        }
                        
                        // Create more distinctive cloud shapes
                        float cloudShaping = pow(cloudVal, 1.0 / _CloudDensity);
                        
                        // Add slight variation to cloud color based on height for more natural appearance
                        fixed4 adjustedCloudColor = _CloudColor;
                        adjustedCloudColor.rgb *= (0.9 + 0.1 * (1.0 - dir.y)); // Slightly brighter clouds at horizon
                        
                        // Add subtle blue tint to cloud shadows for atmospheric effect
                        fixed4 cloudShadowColor = _SkyColor;
                        cloudShadowColor.rgb *= 0.9; // Slightly darker than sky
                        
                        // Apply clouds with shadowing, fading out as we look up
                        float cloudShadowAmount = cloudShaping * 0.4 * cloudHeightMask; // Softer shadow area
                        col = lerp(col, lerp(cloudShadowColor, adjustedCloudColor, 0.5), cloudShadowAmount);
                        col = lerp(col, adjustedCloudColor, cloudShaping * 0.7 * cloudHeightMask);
                    }
                }
                
                // Apply dithering if enabled
                if (_DitherEffect > 0.5) {
                    // Get screen position for dither pattern lookup
                    float2 screenPos = i.vertex.xy / _ScreenParams.xy;
                    int x = int(fmod(screenPos.x * _ScreenParams.x, 4));
                    int y = int(fmod(screenPos.y * _ScreenParams.y, 4));
                    float dither = ditherPattern[y * 4 + x];
                    
                    // Apply dither pattern
                    col.rgb += (dither - 0.5) * _DitherAmount;
                }
                
                // Apply color banding for retro look
                col.rgb = floor(col.rgb * _ColorBanding) / _ColorBanding;
                
                return col;
            }
            ENDCG
        }
    }
    
    Fallback Off
}