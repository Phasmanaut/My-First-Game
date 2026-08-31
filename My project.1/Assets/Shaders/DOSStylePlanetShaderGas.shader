Shader "Custom/DOSStylePlanetShaderGas"
{
    Properties
    {
        [Header(Base Colors)]
        _PrimaryColor ("Primary Band Color", Color) = (0.8, 0.7, 0.4, 1.0)
        _SecondaryColor ("Secondary Band Color", Color) = (0.5, 0.4, 0.3, 1.0)
        
        [Header(Additional Band Colors)]
        [Toggle] _UseTertiaryColor ("Use Tertiary Color", Float) = 0
        _TertiaryColor ("Tertiary Band Color", Color) = (0.4, 0.5, 0.6, 1.0)
        [Toggle] _UseQuaternaryColor ("Use Quaternary Color", Float) = 0
        _QuaternaryColor ("Quaternary Band Color", Color) = (0.6, 0.3, 0.2, 1.0)
        [Toggle] _UseQuinaryColor ("Use Quinary Color", Float) = 0
        _QuinaryColor ("Quinary Band Color", Color) = (0.2, 0.4, 0.3, 1.0)
        
        [Space(10)]
        [Header(Atmosphere)]
        _AtmosphereColor ("Atmosphere Color", Color) = (0.9, 0.8, 0.6, 1.0)
        _AtmosphereSize ("Atmosphere Size", Range(0.0, 1.0)) = 0.3
        _AtmosphereIntensity ("Atmosphere Intensity", Range(0.0, 1.0)) = 0.6
        [Space(10)]
        
        [Header(Band Settings)]
        _BandCount ("Band Count", Range(1, 20)) = 6
        _BandContrast ("Band Contrast", Range(0.0, 1.0)) = 0.6
        _MainTurbulence ("Main Turbulence", Range(0.0, 0.5)) = 0.2
        _TurbulenceAnimation ("Turbulence Animation", Range(0.0, 1.0)) = 0.2
        _BandOffset ("Band Offset", Range(-1.0, 1.0)) = 0.0
        
        [Header(Band Noise)]
        _BandNoiseScale ("Band Noise Scale", Range(0.5, 10.0)) = 3.0
        _BandNoiseStrength ("Band Noise Strength", Range(0.0, 0.5)) = 0.2
        _BandEdgeDistortion ("Band Edge Distortion", Range(0.0, 0.5)) = 0.1
        _BandBlending ("Band Blending", Range(0.0, 1.0)) = 0.3
        [Space(10)]
        
        [Header(Storm Feature)]
        [Toggle] _UseStorm ("Enable Storm", Float) = 0
        _StormColor ("Storm Color", Color) = (0.8, 0.3, 0.2, 1.0)
        _StormSize ("Storm Size", Range(0.01, 0.5)) = 0.1
        _StormPosition ("Storm Position", Vector) = (0.7, 0.3, 0, 0)
        
        [Toggle] _UseSecondStorm ("Enable Second Storm", Float) = 0
        _StormColor2 ("Storm 2 Color", Color) = (0.2, 0.6, 0.8, 1.0)
        _StormSize2 ("Storm 2 Size", Range(0.01, 0.5)) = 0.08
        _StormPosition2 ("Storm 2 Position", Vector) = (0.3, 0.7, 0, 0)
        [Space(10)]
        
        [Header(DOS Style Settings)]
        _FlatShading ("Flat Shading", Range(0, 1)) = 0
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
            
            // Base colors
            float4 _PrimaryColor;
            float4 _SecondaryColor;
            
            // Additional colors
            float _UseTertiaryColor;
            float4 _TertiaryColor;
            float _UseQuaternaryColor;
            float4 _QuaternaryColor;
            float _UseQuinaryColor;
            float4 _QuinaryColor;
            
            // Atmosphere
            float4 _AtmosphereColor;
            float _AtmosphereSize;
            float _AtmosphereIntensity;
            
            // Band settings
            float _BandCount;
            float _BandContrast;
            float _MainTurbulence;
            float _TurbulenceAnimation;
            float _BandOffset;
            
            // Band noise
            float _BandNoiseScale;
            float _BandNoiseStrength;
            float _BandEdgeDistortion;
            float _BandBlending;
            
            // Storm settings
            float _UseStorm;
            float4 _StormColor;
            float _StormSize;
            float4 _StormPosition;
            
            float _UseSecondStorm;
            float4 _StormColor2;
            float _StormSize2;
            float4 _StormPosition2;
            
            // DOS style settings
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
            
            // Simple noise function (more stable than previous version)
            float hash(float2 p)
            {
                p = frac(p * float2(123.4, 234.5));
                p += dot(p, p + 34.5);
                return frac(p.x * p.y);
            }
            
            // 2D Perlin-style noise
            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                
                // Smoothstep for more natural interpolation
                float2 u = f * f * (3.0 - 2.0 * f);
                
                float a = hash(i + float2(0, 0));
                float b = hash(i + float2(1, 0));
                float c = hash(i + float2(0, 1));
                float d = hash(i + float2(1, 1));
                
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }
            
            // Simplified fractal Brownian motion
            float fbm(float2 p, int octaves)
            {
                float value = 0.0;
                float amplitude = 0.5;
                float frequency = 1.0;
                
                for (int i = 0; i < octaves; i++)
                {
                    value += amplitude * noise(p * frequency);
                    amplitude *= 0.5;
                    frequency *= 2.0;
                }
                
                return value;
            }
            
            // Simple function for storm shapes
            float circle(float2 p, float2 center, float radius)
            {
                return smoothstep(radius, radius - 0.05, length(p - center));
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.objectPos = v.vertex.xyz;
                o.flatNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // Choose between flat shading and regular shading
                float3 normal = lerp(i.worldNormal, i.flatNormal, _FlatShading);
                normal = normalize(normal);
                
                // Basic lighting calculation
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float ndotl = max(0, dot(normal, lightDir));
                
                // Calculate ambient term
                float ambient = 1.0 - _ShadowIntensity;
                
                // Quantize lighting to stepped bands
                float lightIntensity = Quantize(ndotl, _LightLevels);
                
                // Calculate bands with turbulence
                float2 noiseCoord = float2(i.objectPos.x, i.objectPos.z) * _BandNoiseScale;
                float timeOffset = _Time.y * _TurbulenceAnimation * 0.2;
                
                // Main band noise
                float mainNoise = fbm(noiseCoord + timeOffset, 2) * _MainTurbulence;
                
                // Additional band noise for more detail
                float detailNoise = noise(noiseCoord * 2.5 + timeOffset * 1.3) * _BandNoiseStrength;
                
                // Edge distortion noise
                float edgeNoise = noise(noiseCoord * 0.7 - timeOffset) * _BandEdgeDistortion;
                
                // Calculate band position with noise
                float bandPos = i.objectPos.y + mainNoise + detailNoise + edgeNoise + _BandOffset;
                
                // Calculate basic band value
                float bandValue = (sin(_BandCount * 3.14159 * bandPos) + 1.0) * 0.5;
                
                // Apply contrast with smoothing
                float contrastMid = 0.5;
                float contrastAdjust = max(0.1, _BandContrast);
                bandValue = (bandValue - contrastMid) * contrastAdjust + contrastMid;
                bandValue = saturate(bandValue);
                
                // Determine color band (0-4) with smooth transitions
                float colorBandFloat = bandValue * 5.0;
                int colorBand = floor(colorBandFloat);
                float colorBlend = frac(colorBandFloat);
                
                // Apply band blending smoothing
                colorBlend = lerp(step(0.5, colorBlend), colorBlend, _BandBlending);
                
                // Set up band colors
                float4 bandColors[5];
                bandColors[0] = _PrimaryColor;
                bandColors[1] = _SecondaryColor;
                bandColors[2] = _UseTertiaryColor > 0.5 ? _TertiaryColor : _PrimaryColor;
                bandColors[3] = _UseQuaternaryColor > 0.5 ? _QuaternaryColor : bandColors[1];
                bandColors[4] = _UseQuinaryColor > 0.5 ? _QuinaryColor : bandColors[0];
                
                // Select current and next band colors (with wrap-around)
                colorBand = colorBand % 5;
                int nextBand = (colorBand + 1) % 5;
                
                // Blend between band colors
                float4 planetColor = lerp(bandColors[colorBand], bandColors[nextBand], colorBlend);
                
                // Calculate sphere UV coordinates for storms
                float2 sphereUV;
                sphereUV.x = 0.5 + atan2(i.objectPos.z, i.objectPos.x) / (2.0 * 3.14159);
                sphereUV.y = 0.5 - asin(i.objectPos.y) / 3.14159;
                
                // Add storm feature if enabled
                if (_UseStorm > 0.5)
                {
                    // Create storm with slight noise
                    float stormNoise = noise(sphereUV * 30.0) * 0.03;
                    float stormMask = circle(sphereUV, _StormPosition.xy, _StormSize + stormNoise);
                    
                    // Mix storm color
                    planetColor = lerp(planetColor, _StormColor, stormMask);
                }
                
                // Add second storm if enabled
                if (_UseSecondStorm > 0.5)
                {
                    // Create second storm with slightly different noise
                    float storm2Noise = noise(sphereUV * 40.0 + 10.0) * 0.03;
                    float storm2Mask = circle(sphereUV, _StormPosition2.xy, _StormSize2 + storm2Noise);
                    
                    // Mix second storm color
                    planetColor = lerp(planetColor, _StormColor2, storm2Mask);
                }
                
                // Apply lighting
                planetColor.rgb *= lerp(ambient, 1.0, lightIntensity);
                
                // Add atmosphere rim effect
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float rim = 1.0 - saturate(dot(viewDir, normal));
                rim = pow(rim, 5.0 * (1.0 - _AtmosphereSize)) * _AtmosphereIntensity;
                planetColor.rgb = lerp(planetColor.rgb, _AtmosphereColor.rgb, rim);
                
                // Quantize colors for DOS style
                planetColor.rgb = QuantizeColor(planetColor.rgb, _ColorLevels);
                
                return planetColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}