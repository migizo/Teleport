Shader "Custom/Shockwave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _EmissionColor ("Emission Color", Color) = (0,0,0)
        _DimPerLifetime ("Diminish Per Lifetime", Range(0, 30.0)) = 4
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="AlphaTest" }
        LOD 100

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

            float remap(float vin, float vinMin, float vinMax, float voutMin, float voutMax) {
              return ((vin-vinMin)/(vinMax-vinMin)) * (voutMax-voutMin) + voutMin;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _EmissionColor;
            float _DimPerLifetime;

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
                float rand = i.uv.z;
                float lifePer = i.uv.w;

                // 0.0~1.0 -> -0.5~0.5
                float2 st = i.uv.xy - float2(0.5, 0.5);

                float dist = length(st) * 2.0;
                float theta = atan2(st.y, st.x);

                dist = clamp(0, 1, pow(dist, 1 + lifePer * _DimPerLifetime));

                // polar to cartesian
                float2 cart = float2(cos(theta)*dist, sin(theta)*dist);

                // texture data
                fixed4 col = tex2D(_MainTex, (cart * 0.5 + float2(0.5, 0.5)) * _MainTex_ST.xy + _MainTex_ST.zw).r;
                col *= i.color;

                // discard
                clip(col.a-0.001);

                // apply HDR
                col.rgb += _EmissionColor.rgb;
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
