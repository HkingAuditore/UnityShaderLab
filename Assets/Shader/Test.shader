Shader "FFD/Shadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "autolight.cginc"
            
            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                float2 uv: TEXCOORD2;
                SHADOW_COORDS(3)
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                TRANSFER_SHADOW(o);
                return o;
            }
            fixed4 frag(v2f i): SV_Target
            {
                // return fixed4(i.uv, 0 , 1);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                col = col * atten; //最终影响光照
                return col;
            }
            ENDCG
            
        }
        
        pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"
            struct v2f
            {
                float4 pos: SV_POSITION;
            };
            
            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }
            
            float4 frag(v2f o): SV_Target
            {
                SHADOW_CASTER_FRAGMENT(o)
            }
            
            ENDCG
            
        }
    }
}
