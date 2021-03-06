﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Welkin/Texture Splatting with First Light PBS"{
	
	Properties{
		_MainTex ("MainTex", 2D) = "white"
		[NoScaleOffset] _SubTex0 ("SubTex0", 2D) = "white" {}
		[NoScaleOffset] _SubTex1 ("SubTex1", 2D) = "white" {}
		[NoScaleOffset] _SubTex2 ("SubTex2", 2D) = "white" {}
		[NoScaleOffset] _SubTex3 ("SubTex3", 2D) = "white" {}
		[NoScaleOffset] _SubTex4 ("SubTex4", 2D) = "white" {}
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
		_Rate ("Rate", Range(0, 10)) = 0.5
		_BlurRate ("BlurRate", Range(0, 10)) = 0.5
		_Gloss ("Gloss", Range(0, 1)) = 0.5
	}

	SubShader{
		Pass{

			Tags{
				"Queue" = "Opaque"
				"LightMode" = "ForwardBase"
				
				
			}

			CGPROGRAM
			
			#pragma target 3.0

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			#pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
			#include "UnityPBSLighting.cginc"
			#include "UnityStandardBRDF.cginc"
			#include "Lighting.cginc" 
			#include "AutoLight.cginc"

			sampler2D _MainTex,_SubTex0, _SubTex1, _SubTex2, _SubTex3, _SubTex4;
			float4 _MainTex_ST;
			float _Metallic;
			float _Smoothness;
			float _Gloss;
			float _Rate;
			float _BlurRate;

			struct VertexData{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct Interpolators{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvSplat : TEXCOORD1;
				float3 normal : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			Interpolators MyVertexProgram(VertexData v){
				Interpolators i;
				i.pos = UnityObjectToClipPos(v.position);
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				i.uvSplat = v.uv;
				i.normal = UnityObjectToWorldNormal(v.normal);
				i.worldPos = mul(unity_ObjectToWorld, v.position);
				TRANSFER_SHADOW(i);
				
				return i;
			}
			

			float4 MyFragmentProgram(Interpolators i) : SV_TARGET {

				float4 splat = tex2D(_MainTex, i.uvSplat);
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				i.normal = normalize(i.normal);
				float background = 0;
				float part1 = (splat.r-(1/_Rate))>0.5?(splat.r):((splat.r-(1/_Rate))-0.5)*_BlurRate;
				float part2 = splat.g>(1/_Rate)?(splat.g):0;
				float part3 = splat.b>(1/_Rate)?(splat.b):0;
				float part4 = (1 - splat.r - splat.g - splat.b)>(1/_Rate)?((1 - splat.r - splat.g - splat.b)):0;
				// float part1 = splat.r>_Rate?splat.r:0;
				// float part2 = splat.g>_Rate?splat.g:0;
				// float part3 = splat.b>_Rate?splat.b:0;
				// float part4 = (1 - splat.r - splat.g - splat.b)>_Rate?(1 - splat.r - splat.g - splat.b):0;
				//return fixed4(part1,part1,part1,1);
				if(part1 == 0 && part2 == 0 && part3 == 0 && part4 == 0){
					background = 1;
				}

				float4 albedo0 = tex2D(_SubTex0, i.uv) * background;
				
				float4 albedo1 = tex2D(_SubTex1, i.uv) * part1;
				float4 albedo2 = tex2D(_SubTex2, i.uv) * part2;
				float4 albedo3 = tex2D(_SubTex3, i.uv) * part3;
				float4 albedo4 = tex2D(_SubTex4, i.uv) * part4;

				float4 albedo = albedo0 + albedo1 + albedo2 + albedo3 +albedo4;
				//if (albedo.r == 0 && albedo4.g ==0)
				// float4 albedo = 
				// 	tex2D(_SubTex1, i.uv) * splat.r + 
				// 	tex2D(_SubTex2, i.uv) * splat.g +
				// 	tex2D(_SubTex3, i.uv) * splat.b +
				// 	tex2D(_SubTex4, i.uv) * (1 - splat.r - splat.g - splat.b);
					
				//return albedo*atten;
				//albedo *= (0.5*atten);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				// albedo *= atten;
				albedo += fixed4(ambient,1);
				float3 specularTint;
				float oneMinusReflectivity;
				DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);

				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 normalDir = i.normal;
				float3 viewReflectDir = reflect( -viewDir, normalDir);

				UnityLight light;
				light.color = _LightColor0.rgb;
				light.dir = _WorldSpaceLightPos0.xyz;
				light.ndotl = DotClamped(i.normal, light.dir);
				light.color *= atten;
				//return fixed4(light.color,1);
 				
				UnityIndirect indirectLight;
				indirectLight.diffuse = UNITY_LIGHTMODEL_AMBIENT;
				indirectLight.specular = UNITY_LIGHTMODEL_AMBIENT;
				


				// return albedo;
				return UNITY_BRDF_PBS(
					albedo, specularTint,
					oneMinusReflectivity, _Smoothness,
					i.normal, viewDir,
					light,indirectLight
				);
			}
			// float4 MyFragmentProgram(Interpolators i) : SV_TARGET {
			// 	float4 splat = tex2D(_MainTex, i.uvSplat);
			// 	return 

			// 		tex2D(_SubTex1, i.uv) * splat.r + 
			// 		tex2D(_SubTex2, i.uv) * splat.g +
			// 		tex2D(_SubTex3, i.uv) * splat.b +
			// 		tex2D(_SubTex4, i.uv) * (1 - splat.r - splat.g - splat.b);
			// }

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