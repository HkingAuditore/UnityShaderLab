// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Parallex"
{

//屬性
Properties{
_Diffuse("Diffuse", Color) = (1,1,1,1)
_MainTex("Base 2D", 2D) = "white"{}
_BumpMap("Bump Map", 2D) = "bump"{}
_HeightMap("Height Map", 2D) = "black"{}
_HeightFactor ("Height Scale", Range(0, 0.1)) = 0.05
}
//子著色器	
SubShader
{
Pass
{
//定義Tags
Tags{ "RenderType" = "Opaque" }
CGPROGRAM
//引入標頭檔案
#include "Lighting.cginc"
//定義Properties中的變數
fixed4 _Diffuse;
sampler2D _MainTex;
//使用了TRANSFROM_TEX巨集就需要定義XXX_ST
float4 _MainTex_ST;
sampler2D _BumpMap;
float _HeightFactor;
sampler2D _HeightMap;
//定義結構體：vertex shader階段輸出的內容
struct v2f
{
float4 pos : SV_POSITION;
//轉化紋理座標
float2 uv : TEXCOORD0;
//tangent空間的光線方向
float3 lightDir : TEXCOORD1;
//需要視線方向
float3 viewDir : TEXCOORD2;
};
//計算uv偏移值
inline float2 CaculateParallaxUV(v2f i)
{
//取樣heightmap
float height = tex2D(_HeightMap, i.uv).r;
//normalize view Dir
float3 viewDir = normalize(i.viewDir);
//偏移值 = 切線空間的視線方向.xy（uv空間下的視線方向）* height * 控制係數
float2 offset = viewDir.xy / viewDir.z * height * _HeightFactor;
return offset;
}
//定義頂點shader
v2f vert(appdata_tan v)
{
v2f o;
o.pos = UnityObjectToClipPos(v.vertex);
//這個巨集為我們定義好了模型空間到切線空間的轉換矩陣rotation，注意後面有個；
TANGENT_SPACE_ROTATION;
//ObjectSpaceLightDir可以把光線方向轉化到模型空間，然後通過rotation再轉化到切線空間
o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
//通過TRANSFORM_TEX巨集轉化紋理座標，主要處理了Offset和Tiling的改變,預設時等同於o.uv = v.texcoord.xy;
o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
//計算觀察方向
o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
return o;
}
//定義片元shader
fixed4 frag(v2f i) : SV_Target
{
//unity自身的diffuse也是帶了環境光，這裡我們也增加一下環境光
fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse.xyz;
float2 uvOffset = CaculateParallaxUV(i);
i.uv  = uvOffset;
//直接解出切線空間法線
float3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
//normalize一下切線空間的光照方向
float3 tangentLight = normalize(i.lightDir);
//蘭伯特光照
fixed3 lambert = saturate(dot(tangentNormal, tangentLight));
//最終輸出顏色為lambert光強*材質diffuse顏色*光顏色
fixed3 diffuse = lambert * _Diffuse.xyz * _LightColor0.xyz+ ambient;
//進行紋理取樣
fixed4 color = tex2D(_MainTex, i.uv);
return fixed4(diffuse * color.rgb, 1.0);
}
//使用vert函式和frag函式
#pragma vertex vert
#pragma fragment frag	
ENDCG
}
}
//前面的Shader失效的話，使用預設的Diffuse
FallBack "Diffuse"

}
