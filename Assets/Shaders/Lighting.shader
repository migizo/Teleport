Shader "Custom/Lighting"
{
    Properties
    {
        _NoiseTex ("NoiseTexture", 2D) = "white" {}
        [HDR] _EmissionColor ("Emission Color", Color) = (0,0,0)
        _NoiseSpeed ("Noise Speed", Range(0.0, 1.0)) = 0.5
        _NoiseAmount ("Noise Amount", Float) = 0.1
        _LineWidth ("Line Width", Float) = 0.05
        _Power ("Power", Range(0.1, 200.0)) = 200
        _FadeArea ("Fade Area", Range(0.001, 1.0)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha 
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                fixed4 color: COLOR;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                fixed4 color: COLOR;
            };

            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float _NoiseSpeed;
            float _NoiseAmount;
            float _LineWidth;
            float _Power;
            float _FadeArea;
            float4 _EmissionColor;

            float drawLine(float st, float lineWidth) {
              return smoothstep(0.5-lineWidth/2, 0.5, st)
                     * smoothstep(0.5+lineWidth/2, 0.5, st);
            }
            float drawLine(float st, float lineWidth, float fadeWidth) {
              return smoothstep(0.5-lineWidth/2-fadeWidth/2, 0.5-lineWidth/2, st)
                     * smoothstep(0.5+lineWidth/2+fadeWidth/2, 0.5+lineWidth/2, st);
            }
            float remap(float vin, float vinMin, float vinMax, float voutMin, float voutMax) {
              return ((vin-vinMin)/(vinMax-vinMin)) * (voutMax-voutMin) + voutMin;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv.zw = v.uv.zw;
                o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // noise for uv displacement
                float2 noiseTime;
                noiseTime.x = (i.uv.z - _Time.w * (1.0 + i.uv.w));
                noiseTime.y = noiseTime.x;
                noiseTime *= _NoiseSpeed;
                float2 noise = tex2D(_NoiseTex, i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw + noiseTime.yy).rb;
                noise.x = ((noise.x - 0.5) * 2.0) * _NoiseAmount;
                
                fixed4 col = i.color;

                // noisy line
                col.r = drawLine(i.uv.x + noise.x, _LineWidth);
                col.r = pow(col.r, _Power);

                // discard
                clip (col.r - 0.1);

                // adjust color
                col.r = remap(col.r, 0.0, 1.0, 0.1, 0.7);
                col.gb = col.rr;

                // adjust alpha
                col.a *= max(col.r, max(col.g, col.b));
                col.a *= step(0.2, noise.y);

                // apply HDR
                col.rgb += _EmissionColor.rgb;

                // fade mesh edge
                col *= drawLine(i.uv.y, 1.0 - _FadeArea, _FadeArea);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
