// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/GeometryShader"
{

    Properties
    {
        Height("SingleH",float)=0.5
    }
    SubShader
    {
        Pass
        {

            Tags
            {
                "RenderType"="Opaque"
            }
            Cull Off
            
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex VS_Main
            #pragma geometry GS_Main
            #pragma fragment FS_Main			
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            			
            float Height;		
            struct GS_INPUT
            {
                float4 pos:POSITION;
                fixed3 color : COLOR;
            };			
            struct FS_INPUT
            {
                float4 pos:SV_POSITION;
                fixed3 color : COLOR;
            };			
            
            GS_INPUT VS_Main(appdata_base v)
            {
                GS_INPUT output;
                output.pos=v.vertex;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * fixed3(1,1,1) * saturate(dot(worldNormal, worldLight));

                output.color = diffuse + ambient;
                return output;
            };
            //vs的输出作为gs的输入
            [maxvertexcount(3)]
            //输入 point line triangle lineadj triangleadj----输出: PointStream只显示点，LineStream只显示线，TriangleStream全显
            void GS_Main(triangle GS_INPUT p[3],inout TriangleStream<FS_INPUT> triStream)
            {
                for(int i=0;i<3;i++)
                {
                    FS_INPUT output;
                     // 读取原来的点，这里不做改变
                    float4 pos=float4(p[i].pos.x + sin(_Time.y * p[i].pos.y) * 0.01,p[i].pos.y,p[i].pos.z,p[i].pos.w);								
                    output.pos=UnityObjectToClipPos(pos);
                    output.color = p[i].color;
                    if(pos.y<Height)
                    {
                        triStream.Append(output);
                    }					
                }
                triStream.RestartStrip();
            }
            //gs的输出作为fs的输入
            float4 FS_Main(FS_INPUT i):COLOR
            {
                return float4(i.color,1);
            }			
            ENDCG
        }
    }
}
