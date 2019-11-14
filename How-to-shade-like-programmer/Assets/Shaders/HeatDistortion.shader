Shader "Presentation/HeatDistortion"
{
    Properties
    {
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _MaskTex("Mask where effect is applied", 2D) = "white" {}
        _Speed ("Speed of effect", Float) = 1
        _Coef ("How strong is effect", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        ZTest Always

        GrabPass
        {
            "_BackgroundTex"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _BackgroundTex;
            float4 _BackgroundTex_ST;
            
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            
            float _Speed;
            float _Coef;

            v2f vert (appdata v)
            {
                // Rotating plane towards camera
                v2f o;
                float3 originViewSpace = UnityObjectToViewPos(float3(0,0,0));
                float4 vertexInViewSpace = float4(originViewSpace, 1) + float4(v.vertex.xz, 0, 0); 
                o.vertex = mul(UNITY_MATRIX_P, vertexInViewSpace);
               
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                
                // Distorting 
                float noise = tex2Dlod(_NoiseTex, float4(v.uv, 0, 0)).rgb;
                float mask = tex2Dlod(_MaskTex, float4(v.uv, 0, 0)).rgb;  // Could be done with
                
                // Mask only
                //o.grabPos.x += cos(_Time.y * _Speed) * mask * _Coef;
                //o.grabPos.y += sin(_Time.y * _Speed) * mask * _Coef;
                
                o.grabPos.x += cos(noise * _Time.y * _Speed) * mask * _Coef;
                o.grabPos.y += sin(noise * _Time.y * _Speed) * mask * _Coef;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //return float4(0.2,0.2,0.2,0.2);
                
                fixed4 col = tex2Dproj(_BackgroundTex, i.grabPos);
                return col;
            }
            ENDCG
        }
    }
}
