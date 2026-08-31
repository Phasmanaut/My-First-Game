Shader "Custom/DOSStylePlanetShader"
{
    Properties
    {
        _WaterColor ("Water Color", Color) = (0.1, 0.3, 0.6, 1.0)
        _LandColor ("Land Color", Color) = (0.3, 0.5, 0.2, 1.0)
        _AtmosphereColor ("Atmosphere Color", Color) = (0.7, 0.8, 1.0, 1.0)
        _AtmosphereSize ("Atmosphere Size", Range(0.0, 1.0)) = 0.3
        _AtmosphereIntensity ("Atmosphere Intensity", Range(0.0, 1.0)) = 0.6
        [Space(10)]
        
        [Header(Planet Features)]
        _NoiseScale ("Continent Scale", Range(0.5, 10.0)) = 2.0
        _NoiseThreshold ("Continent Coverage", Range(0.0, 1.0)) = 0.5
        _FlatShading ("Flat Shading", Range(0, 1)) = 0
        [Space(10)]
        
        [Header(DOS Style Settings)]
        _ColorLevels ("Color Levels", Range(2, 32)) = 8
        _LightLevels ("Light Steps", Range(1, 16)) = 4
        _ShadowIntensity ("Shadow Darkness", Range(0, 1)) = 0.6
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
            #include "Lighting.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 objectPos : TEXCOORD2;
                nointerpolation float3 flatNormal : TEXCOORD3;
            };
            
            float4 _WaterColor;
            float4 _LandColor;
            float4 _AtmosphereColor;
            float _AtmosphereSize;
            float _AtmosphereIntensity;
            float _NoiseScale;
            float _NoiseThreshold;
            float _FlatShading;
            float _ColorLevels;
            float _LightLevels;
            float _ShadowIntensity;
            
            // Quantization functions
            float Quantize(float value, float levels)
            {
                return floor(value * (levels - 1) + 0.5) / (levels - 1);
            }
            
            float3 QuantizeColor(float3 color, float levels)
            {
                return float3(
                    Quantize(color.r, levels),
                    Quantize(color.g, levels),
                    Quantize(color.b, levels)
                );
            }
            
            // Simple hash function for noise
            float hash(float3 p)
            {
                p = frac(p * 0.3183099 + 0.1);
                p *= 17.0;
                return frac(p.x * p.y * p.z * (p.x + p.y + p.z));
            }
            
            // Noise function for continent generation
            float noise(float3 x)
            {
                float3 p = floor(x);
                float3 f = frac(x);
                f = f * f * (3.0 - 2.0 * f);
                
                float n = p.x + p.y * 157.0 + 113.0 * p.z;
                return lerp(
                    lerp(lerp(hash(p + float3(0, 0, 0)), 
                              hash(p + float3(1, 0, 0)), f.x),
                         lerp(hash(p + float3(0, 1, 0)), 
                              hash(p + float3(1, 1, 0)), f.x), f.y),
                    lerp(lerp(hash(p + float3(0, 0, 1)), 
                              hash(p + float3(1, 0, 1)), f.x),
                         lerp(hash(p + float3(0, 1, 1)), 
                              hash(p + float3(1, 1, 1)), f.x), f.y), f.z);
            }
            
            // Fractal Brownian Motion for more natural patterns
            float fbm(float3 pos)
            {
                float value = 0.0;
                float amplitude = 0.5;
                float frequency = 1.0;
                
                for (int i = 0; i < 4; i++)
                {
                    value += amplitude * noise(pos * frequency);
                    amplitude *= 0.5;
                    frequency *= 2.0;
                }
                
                return value;
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.objectPos = v.vertex.xyz;
                // Store flat normal (same for all vertices in the triangle)
                o.flatNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // Choose between flat shading and regular shading
                float3 normal = lerp(i.worldNormal, i.flatNormal, _FlatShading);
                normal = normalize(normal);
                
                // Light direction
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                
                // Basic lighting calculation
                float ndotl = max(0, dot(normal, lightDir));
                
                // Calculate ambient term
                float ambient = 1.0 - _ShadowIntensity;
                
                // Quantize lighting to stepped bands
                float lightIntensity = Quantize(ndotl, _LightLevels);
                
                // Generate continent pattern using fbm noise
                float landPattern = fbm(i.objectPos * _NoiseScale);
                float isLand = step(_NoiseThreshold, landPattern);
                
                // Mix water and land colors based on the pattern
                float4 planetColor = lerp(_WaterColor, _LandColor, isLand);
                
                // Apply quantized lighting
                planetColor.rgb *= lerp(ambient, 1.0, lightIntensity);
                
                // Add atmosphere rim effect
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float rim = 1.0 - saturate(dot(viewDir, normal));
                rim = pow(rim, 5.0 * (1.0 - _AtmosphereSize)) * _AtmosphereIntensity;
                planetColor.rgb = lerp(planetColor.rgb, _AtmosphereColor.rgb, rim);
                
                // Quantize the final color to reduce color depth (DOS style)
                planetColor.rgb = QuantizeColor(planetColor.rgb, _ColorLevels);
                
                return planetColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}