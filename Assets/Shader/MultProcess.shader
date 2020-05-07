// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Test/MultProcessing" {
	Properties {
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
		_SubTex0("Sub Tex0", 2D) = "white" {}
		_SubTex1("Sub Tex1", 2D) = "white" {}
		_SubTex2("Sub Tex2", 2D) = "white" {}
		_SubTex3("Sub Tex3", 2D) = "white" {}
		_Cutoff("Alpha Cutoff Main", Range(0, 1)) = 0.5
		_Cutoff0("Alpha Cutoff 0", Range(0, 1)) = 0.5
		_Cutoff1("Alpha Cutoff 1", Range(0, 1)) = 0.5
		_Cutoff2("Alpha Cutoff 2", Range(0, 1)) = 0.5
	} 
	SubShader {
		Tags {
			"Queue" = "AlphaTest"
			"IgnoreProjector" = "True"
			"RenderType" = "TransparentCutout"
		}

		Pass {
			Tags {
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM
			# pragma vertex vert
			# pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _SubTex0;
			float4 _SubTex0_ST;
			sampler2D _SubTex1;
			float4 _SubTex1_ST;
			sampler2D _SubTex2;
			float4 _SubTex2_ST;
			sampler2D _SubTex3;
			float4 _SubTex3_ST;
			fixed _Cutoff;
			fixed _Cutoff0;
			fixed _Cutoff1;
			fixed _Cutoff2;

			struct a2v {
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float4 texcoord: TEXCOORD0;
			};

			struct v2f {
				float4 pos: SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
				float2 uv: TEXCOORD2;
				float2 uvSplat: TEXCOORD3;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				o.uvSplat = v.texcoord;

				return o;
			}

			fixed4 frag(v2f i): SV_Target {

				float4 splat = tex2D(_MainTex,i.uvSplat);
				fixed4 splatTex = (tex2D(_SubTex0,i.uv)*splat.r + 
								   tex2D(_SubTex1,i.uv)*splat.g +
								   tex2D(_SubTex2,i.uv)*splat.b +
								   tex2D(_SubTex3,i.uv)*(1 - splat.r - splat.g -splat.b),1.0);
				 return splatTex;



				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 texColor = tex2D(_MainTex, i.uv);
				clip(texColor.a - _Cutoff);
				/* if((texColor.a - _CutoffMain)<0.0){
					discard;
				} */
				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				return fixed4(ambient + diffuse, 1.0);
			}

			ENDCG
		}
	}
	// FallBack "Transparent/Cutout/VertexLit"
}
