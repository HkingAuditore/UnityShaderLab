Shader "Test/MultProcess"
{
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
	}
	Category{
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		SubShader {	
			Pass {
				Tags { "LightMode"="ForwardBase" }
				
				CGPROGRAM
				#include "MultProcess.cginc"		
				ENDCG
			}
		} 
			FallBack "Transparent/Cutout/VertexLit"
	}
}