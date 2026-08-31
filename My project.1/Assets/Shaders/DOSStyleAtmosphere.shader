Shader "Custom/DOSStyleAtmosphere"
{
    Properties
    {
        [Header(Atmosphere Colors)]
        _InnerColor ("Inner Color", Color) = (0.8, 0.9, 1.0, 0.1)
        _OuterColor ("Outer Color", Color) = (0.5, 0.7, 1.0, 0.0)
        
        [Header(Atmosphere Settings)]
        _RimPower ("Atmosphere Falloff", Range(0.5, 8.0)) = 3.0
        _RimIntensity ("Atmosphere Intensity", Range(0.1, 5.0)) = 1.5
        _AtmosphereSize ("Atmosphere Size", Range(1.0, 1.2)) = 1.05
        
        [Header(Animation)]
        [Toggle] _UseAnimation ("Animate Atmosphere", Float) = 0
        _AnimationSpeed ("Animation Speed", Range(0.0, 2.0)) = 0.5
        _AnimationIntensity ("Animation Intensity", Range(0.0, 0.1)) = 0.02
        
        [Header(Retro DOS Style)]
        _ColorLevels ("Color Levels", Range(2, 32)) = 8
        _Pixelation ("Pixelation", Range(0, 1)) = 0.2
        [Toggle] _UseDistortion ("Use Edge Distortion", Float) = 0
        _DistortionScale ("Distortion Scale", Range(1, 20)) = 10
        _DistortionAmount ("Distortion Amount", Range(0, 0.1)) = 0.02
        
        [Header(Blending)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Float) = 10
        [Toggle] _ZWrite ("ZWrite", Float) = 0
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
        LOD 100
        
        Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]
        Cull Back
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
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
                float3 viewDir : TEXCOORD2;
                float4 screenPos : TEXCOORD3;
            };
            
            float4 _InnerColor;
            float4 _OuterColor;
            float _RimPower;
            float _RimIntensity;
            float _AtmosphereSize;
            float _UseAnimation;
            float _AnimationSpeed;
            float _AnimationIntensity;
            float _ColorLevels;
            float _Pixelation;
            float _UseDistortion;
            float _DistortionScale;
            float _DistortionAmount;
            
            // Quantization function for retro style
            float3 QuantizeColor(float3 color, float levels)
            {
                return floor(color * (levels - 1) + 0.5) / (levels - 1);
            }
            
            // Simple noise function for distortion
            float hash(float2 p)
            {
                p = frac(p * float2(123.4, 234.5));
                p += dot(p, p + 34.5);
                return frac(p.x * p.y);
            }
            
            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                
                // Smoother interpolation
                float2 u = f * f * (3.0 - 2.0 * f);
                
                float a = hash(i + float2(0, 0));
                float b = hash(i + float2(1, 0));
                float c = hash(i + float2(0, 1));
                float d = hash(i + float2(1, 1));
                
                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                
                // Scale vertex slightly to create atmosphere effect
                float3 scaledVertex = v.vertex.xyz * _AtmosphereSize;
                
                // Add subtle animation if enabled
                if (_UseAnimation > 0.5)
                {
                    float time = _Time.y * _AnimationSpeed;
                    float3 noisePos = v.vertex.xyz * 2.0;
                    float n1 = sin(time + noisePos.x + noisePos.y * 0.5) * 0.5 + 0.5;
                    float n2 = cos(time * 0.7 + noisePos.z + noisePos.x * 0.2) * 0.5 + 0.5;
                    
                    // Apply noise-based displacement along normal
                    scaledVertex += v.normal * (n1 * n2 * _AnimationIntensity);
                }
                
                o.vertex = UnityObjectToClipPos(float4(scaledVertex, 1.0));
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, float4(scaledVertex, 1.0)).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // Normalize vectors
                float3 viewDir = normalize(i.viewDir);
                float3 worldNormal = normalize(i.worldNormal);
                
                // Basic rim effect (stronger at grazing angles)
                float rim = 1.0 - saturate(dot(viewDir, worldNormal));
                rim = pow(rim, _RimPower) * _RimIntensity;
                
                // Optional distortion effect
                if (_UseDistortion > 0.5)
                {
                    // Calculate distortion coord based on view angle and time
                    float2 distortCoord = i.screenPos.xy / i.screenPos.w;
                    distortCoord *= _DistortionScale;
                    distortCoord += _Time.y * 0.1;
                    
                    // Apply noise-based distortion
                    float distortion = noise(distortCoord) * _DistortionAmount;
                    rim += distortion;
                }
                
                // Optional pixelation effect
                if (_Pixelation > 0)
                {
                    rim = floor(rim / _Pixelation) * _Pixelation;
                }
                
                // Mix inner and outer colors based on rim factor
                float4 color = lerp(_InnerColor, _OuterColor, rim);
                
                // Boost rim intensity at the edge
                color.a *= rim * rim;
                
                // Apply color quantization for retro effect
                color.rgb = QuantizeColor(color.rgb, _ColorLevels);
                
                return color;
            }
            ENDCG
        }
    }
    
    // Fallback for older GPUs
    FallBack "Transparent/VertexLit"
}