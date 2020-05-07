// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Welkin/Texture Splatting"{
	
	Properties{
		_MainTex ("MainTex", 2D) = "white"
		[NoScaleOffset] _SubTex1 ("SubTex1", 2D) = "white"
		[NoScaleOffset] _SubTex2 ("SubTex2", 2D) = "white"
		[NoScaleOffset] _SubTex3 ("SubTex3", 2D) = "white"
		[NoScaleOffset] _SubTex4 ("SubTex4", 2D) = "white"
	}

	SubShader{
		Pass{
			// Tags {
			// 	"LightMode" = "ShadowCaster"
			// }
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			sampler2D _MainTex, _SubTex1, _SubTex2, _SubTex3, _SubTex4;
			float4 _MainTex_ST;
			

			struct VertexData{
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				
			};

			struct Interpolators{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvSplat : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				float3 wroldPos : TEXCOORD3;
				
			};

			Interpolators MyVertexProgram(VertexData v){
				Interpolators i;
				i.position = UnityObjectToClipPos(v.position);		
				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				i.worldNormal = UnityObjectToWorldNormal(v.position);
				i.worldPos = mul(float4(1,1,1,1),float4(1,1,1,1)).xyz;
				
				i.uvSplat = v.uv;
				return i;
			}

			float4 MyFragmentProgram(Interpolators i) : SV_TARGET {
				float4 splat = tex2D(_MainTex, i.uvSplat);
				return 

					tex2D(_SubTex1, i.uv) * splat.r + 
					tex2D(_SubTex2, i.uv) * splat.g +
					tex2D(_SubTex3, i.uv) * splat.b +
					tex2D(_SubTex4, i.uv) * (1 - splat.r - splat.g - splat.b);
			}

			ENDCG
		}
	}
}