// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Wave" {
	Properties {
	
		_MainTex("Texture", 2D) = "white"{}
		_BumpMainTex("Layer 1 Normal(Bump)", 2D) = "Bump" {}
		_Arange("Amplitute", float) = 1
		_Frequency("Frequency", float) = 2
		_Speed("Speed",float) = 0.5
		_Metallic("Metallic",Range(0, 1)) = 0.5
		_Smoothness("Smoothness",Range(0, 1)) = 0.5
		_Normal("Normal",Range(0, 1)) = 0.5
		_AOColor ("AO Color", Color) = (1,1,1,1)   
 
	}
 
	SubShader
	{
		Pass
		{		
		
		 Tags {
                 "Queue" = "Opaque"
                "LightMode" = "ForwardBase"
                
            }
		
			CGPROGRAM
			#pragma target 3.0

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
			#include "UnityPBSLighting.cginc"
			#include "UnityStandardBRDF.cginc"
			#include "Lighting.cginc" 
			#include "AutoLight.cginc"
			
			struct appdata
			{
				float4 position:POSITION;
				float2 uv:TEXCOORD0;
				float3 normal : NORMAL;
			};
	
			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};
 
            sampler2D _MainTex;
            sampler2D _BumpMainTex;
            float4 _MainTex_ST;
			float _Frequency;
			float _Arange;
			float _Normal;
			float _Speed;
			float _Metallic;
			float _Smoothness;
			fixed4 _AOColor;
 
			v2f vert(appdata v)
			{
                v2f o;
     
                float timer = _Time.y *_Speed;
                float waver = _Arange*sin(timer + v.position.x *_Frequency);
                v.position.y = v.position.y + waver;
                o.pos = UnityObjectToClipPos(v.position);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.position);
                TRANSFER_SHADOW(o);
                return o;
			}
 
			
 
			fixed4 frag(v2f i) :SV_Target
			{
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				i.normal = normalize(i.normal);
				float4 albedo = tex2D(_MainTex, i.uv);
				fixed3 nor1 = UnpackNormal(tex2D (_BumpMainTex, i.uv));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*_AOColor;
				albedo += fixed4(ambient,1);
				float3 specularTint;
				float oneMinusReflectivity;
				DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);

				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 normalDir = i.normal;
				//i.normal = nor1*_Normal;
				float3 viewReflectDir = reflect( -viewDir, normalDir);
				
				UnityLight light;
				light.color = _LightColor0.rgb;
				light.dir = _WorldSpaceLightPos0.xyz;
				light.ndotl = DotClamped(i.normal, light.dir);
				light.color *= atten;
				
				UnityIndirect indirectLight;
				indirectLight.diffuse = UNITY_LIGHTMODEL_AMBIENT;
				indirectLight.specular = UNITY_LIGHTMODEL_AMBIENT;

				
				return UNITY_BRDF_PBS(
					albedo, specularTint,
					oneMinusReflectivity, _Smoothness,
					i.normal, viewDir,
					light,indirectLight
				);
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