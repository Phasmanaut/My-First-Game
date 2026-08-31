Shader "Custom/DOSStyleEmissive"
{
    Properties
    {
        _Color ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _UseTexture ("Use Texture", Range(0, 1)) = 0
        _ColorLevels ("Color Levels", Range(2, 16)) = 8
        [Space(10)]
        [Header(Emissive Settings)]
        _EmissiveColor ("Emissive Color", Color) = (1,1,1,1)
        _EmissiveIntensity ("Emissive Intensity", Range(0, 5)) = 1
        _EmissiveMask ("Emissive Mask (RGB)", 2D) = "white" {}
        _UseMask ("Use Emissive Mask", Range(0, 1)) = 0
        _EmissivePulse ("Pulse Effect", Range(0, 1)) = 0
        _PulseSpeed ("Pulse Speed", Range(0.1, 5)) = 1
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uvEmissive : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _EmissiveMask;
            float4 _EmissiveMask_ST;
            float4 _Color;
            float4 _EmissiveColor;
            float _UseTexture;
            float _UseMask;
            float _ColorLevels;
            float _EmissiveIntensity;
            float _EmissivePulse;
            float _PulseSpeed;
            
            // Quantizes a value to a specific number of levels
            float Quantize(float value, float levels)
            {
                return floor(value * (levels - 1) + 0.5) / (levels - 1);
            }
            
            // Quantizes a color to a specific number of levels per channel
            float3 QuantizeColor(float3 color, float levels)
            {
                return float3(
                    Quantize(color.r, levels),
                    Quantize(color.g, levels),
                    Quantize(color.b, levels)
                );
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvEmissive = TRANSFORM_TEX(v.uv, _EmissiveMask);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // Either use texture or base color based on the UseTexture parameter
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed4 col = lerp(_Color, texColor, _UseTexture);
                
                // Quantize the base color to reduce color depth (DOS style)
                col.rgb = QuantizeColor(col.rgb, _ColorLevels);
                
                // Calculate emissive effect
                float emissiveMask = 1.0;
                if (_UseMask > 0.0) {
                    // Use the emissive mask if specified
                    emissiveMask = tex2D(_EmissiveMask, i.uvEmissive).r;
                }
                
                // Calculate pulse effect if enabled
                float pulseMultiplier = 1.0;
                if (_EmissivePulse > 0.0) {
                    // Create a sine wave pulse between 0.7 and 1.0
                    pulseMultiplier = 0.7 + 0.3 * sin(_Time.y * _PulseSpeed);
                    // Blend between no pulse (1.0) and full pulse effect based on _EmissivePulse
                    pulseMultiplier = lerp(1.0, pulseMultiplier, _EmissivePulse);
                }
                
                // Apply emissive effect - add the emissive color scaled by intensity
                float3 emissive = _EmissiveColor.rgb * _EmissiveIntensity * emissiveMask * pulseMultiplier;
                
                // Add the emissive color to the base
                col.rgb += emissive;
                
                // Final color quantization to maintain DOS aesthetic
                col.rgb = QuantizeColor(col.rgb, _ColorLevels);
                
                return col;
            }
            ENDCG
        }
    }
}