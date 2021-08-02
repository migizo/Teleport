Shader "Custom/EmissiveCylinder"
{
    Properties
    { 
        _NoiseTex ("NoiseTexture", 2D) = "white" {}
        [HDR] _EmissionColor ("Emission Color", Color) = (0,0,0)
        _NoiseFreqX ("Noise Freq X", Range(0.0, 2.0)) = 0.5
        _NoiseFreqY ("Noise Freq Y", Range(0.0, 2.0)) = 0.25
        _NoiseSpeed ("Noise Speed", Range(-2.0, 2.0)) = -0.5
        _NoisePower ("Noise Power", Range(0.0, 8.0)) = 3.0
        _RimAmount ("Rim Amount", Range(0.0, 1.0)) = 0.5
        _FadeWidth ("Fade Width", Range(0.0, 2.0)) = 0.1
        _HeightMax ("Height Max", Range(0.0, 3.0)) = 2.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "AlphaTest"}
        Blend SrcAlpha OneMinusSrcAlpha 
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0; // zw: customData (shuriken)
                float3 normal : NORMAL;
                fixed4 color: COLOR;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 viewDirAndHeight : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                fixed4 color: COLOR;
            };

            sampler2D _NoiseTex;
            float4 _EmissionColor;
            float _NoiseFreqX;
            float _NoiseFreqY;
            float _NoiseSpeed;
            float _NoisePower;
            float _RimAmount;
            float _FadeWidth;
            float _HeightMax;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.uv = v.uv;
                o.normalDir = normalize(UnityObjectToWorldNormal(v.normal));
                o.viewDirAndHeight.xyz = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);
                o.viewDirAndHeight.w = v.vertex.y;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = i.color;

                float customData = i.uv.z;
                float height = i.viewDirAndHeight.w;

                // diminish alpha (by height & all)
                float t = (1-customData) * _HeightMax;
                col.a *= smoothstep(t, t + _FadeWidth, height);
                col.a *= pow(customData,3);

                // discard
                clip (col.a - 0.001);

                // noise for alpha
                float noiseTime = _Time.w * _NoiseSpeed;
                float2 noiseUv = float2(_NoiseFreqX * i.uv.x, _NoiseFreqY * i.uv.y);
                float noise = tex2D(_NoiseTex, noiseUv + float2(0, noiseTime)).r;

                // rim for alpha
                fixed rim = 1.0 - abs(dot(i.viewDirAndHeight.xyz, i.normalDir));

                float intensity = i.uv.w;

                // adjust alpha
                col.a *= max(pow(noise, _NoisePower), max(intensity, rim * _RimAmount));
                col.a *= max(col.r, max(col.g, col.b));

                // apply HDR
                col.rgb += _EmissionColor.rgb;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
