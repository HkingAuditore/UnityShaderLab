
Shader"Test/NewBlend" 
{
    Properties {
        _Splat0 ("Layer 1(RGBA)", 2D) = "white" {}
        _BumpSplat0 ("Layer 1 Normal(Bump)", 2D) = "Bump" {}
        _Splat1 ("Layer 2(RGBA)", 2D) = "white" {}
        _BumpSplat1 ("Layer 2 Normal(Bump)", 2D) = "Bump" {}
        _Splat2 ("Layer 3(RGBA)", 2D) = "white" {}
        _BumpSplat2 ("Layer 3 Normal(Bump)", 2D) = "Bump" {}
        _Splat3 ("Layer 4(RGBA)", 2D) = "white" {}
        _BumpSplat3 ("Layer 4 Normal(Bump)", 2D) = "Bump" {}
        _Tiling3("_Tiling4 x/y", Vector)=(1,1,0,0)
        _Control ("Control (RGBA)", 2D) = "white" {}
        _Weight("Blend Weight" , Range(0.001,2)) = 0.2
        _Tex1Power("Tex1Power" , Range(0.001,2)) = 0.2
        _Tex2Power("Tex2Power" , Range(0.001,2)) = 0.2
        _Tex3Power("Tex3Power" , Range(0.001,2)) = 0.2
        _Tex0Power("Tex0Power" , Range(0.001,2)) = 0.2
        
        
    }
    
    SubShader {
        Tags {
            "SplatCount" = "4"
            "RenderType" = "Opaque"
            
        }
        CGPROGRAM
        #pragma surface surf BlinnPhong addshadow 
        #pragma exclude_renderers xbox360 ps3
        #pragma target 2.0

        struct Input 
        {
            float2 uv_Control : TEXCOORD0;
            float2 uv_Splat0 : TEXCOORD1;
            float2 uv_Splat1 : TEXCOORD2;
            float2 uv_Splat2 : TEXCOORD3;
            //float2 uv_Splat3 : TEXCOORD4;
        };
        
        sampler2D _Control;
        sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
        sampler2D _BumpSplat0,_BumpSplat1,_BumpSplat2,_BumpSplat3;

        float4 _Tiling3;
        float _Weight;
        float _Tex0Power;
        float _Tex1Power;
        float _Tex2Power;
        float _Tex3Power;

        inline half4 Blend(half depth1 ,half depth2,half depth3,half depth4 , fixed4 control) 
        {
            half4 blend ;
            
            blend.r =depth1 * control.r;
            blend.g =depth2 * control.g;
            blend.b =depth3 * control.b;
            blend.a =depth4 * control.a;
            
            half ma = max(blend.r, max(blend.g, max(blend.b, blend.a)));
            blend = max(blend - ma +_Weight , 0) * control;
            //return blend;
            return blend/(blend.r + blend.g + blend.b + blend.a);
        }


        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 splat_control = tex2D (_Control, IN.uv_Control).rgba;
            
            fixed4 lay1 = tex2D (_Splat0, IN.uv_Splat0);
            fixed4 lay2 = tex2D (_Splat1, IN.uv_Splat1);
            fixed4 lay3 = tex2D (_Splat2, IN.uv_Splat2);

            fixed4 lay4 = tex2D (_Splat3, IN.uv_Control*_Tiling3.xy);

            half4 blend = Blend(_Tex1Power*lay1.a,_Tex2Power*lay2.a,_Tex3Power*lay3.a,lay4.a,splat_control*_Tex0Power);
            
            
            o.Alpha = 0.0;
            o.Albedo.rgb = _Tex1Power* blend.r * lay1 + _Tex2Power* blend.g * lay2 + _Tex3Power* blend.b * lay3 + blend.a * lay4;//混合



        }
        ENDCG 
    }
    FallBack "Specular"
}