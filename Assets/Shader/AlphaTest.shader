Shader "Unlit/AlphaTest"
{
Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8, 256)) = 8
        _CutOff("Cut Off", Range(0, 1)) = 0
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCg.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;
            float _CutOff;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldLight : TEXCOORD2;
                float3 worldView : TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldLight = normalize(WorldSpaceLightDir(v.vertex));
                o.worldView = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 albedo = tex2D(_MainTex, i.uv) * i.color;

                // alpha test
                clip(albedo.a - _CutOff);
                // equals to:
                //if(albedo.a - _CutOff < 0)
                //    discard;

                fixed3 ambient = albedo.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 diff = albedo.rgb * _LightColor0.rgb * max(0, dot(i.worldNormal, i.worldLight));
                fixed3 halfDir = normalize(i.worldLight + i.worldView);
                fixed3 spec = albedo.rgb * _Specular.rgb * pow(max(0, dot(halfDir, i.worldNormal)), _Gloss);
                fixed3 col = ambient + diff + spec;
                return fixed4(col, 1);
            }

            ENDCG
        }
    }

    Fallback "Diffuse"
}
