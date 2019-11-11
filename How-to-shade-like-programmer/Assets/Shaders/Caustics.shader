Shader "Presentationex/Caustics"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CausticTex ("Caustic Tex", 2D) = "white" {}
        _Caustic_ONE_ST ("Caustic_ONE_ST", Vector) = (1,1,1,1)
        _Caustic_TWO_ST ("Caustic_TWO_ST", Vector) = (1,1,1,1)
        _CausticsSpeed_1_2 ("_CausticsSpeed_1", Vector) = (1,1,1,1)
        _ColorSplit("ColorSplit", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            sampler2D _CausticTex;
            float4 _Caustic_ONE_ST;
            float4 _Caustic_TWO_ST;
            float4 _CausticsSpeed_1_2;
            float _ColorSplit;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 ColorSplit(fixed2 uv) {
                fixed4 color;
                color.r = tex2D(_CausticTex, uv + float2(_ColorSplit, _ColorSplit)).r;
                color.g = tex2D(_CausticTex, uv + float2(_ColorSplit, -_ColorSplit)).g;
                color.b = tex2D(_CausticTex, uv + float2(-_ColorSplit, -_ColorSplit)).b;
                color.a = tex2D(_CausticTex, uv).a;
                return color;
            }

            fixed4 ApplyCaustic(float2 uv, float2 scale, float2 offset, float2 speed) {
                uv *= scale;
                uv += offset;
                uv += speed * sin(_Time.x);
                //return tex2D(_CausticTex, uv);  // Without color split
                
                return ColorSplit(uv);
            }
            
            

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 color = tex2D(_MainTex, i.uv);
                
                fixed4 caustic_one = ApplyCaustic(i.uv, _Caustic_ONE_ST.xy, _Caustic_ONE_ST.zw, _CausticsSpeed_1_2.xy);
                fixed4 caustic_two = ApplyCaustic(i.uv, _Caustic_TWO_ST.xy, _Caustic_TWO_ST.zw, _CausticsSpeed_1_2.zw);
                
                //return caustic_two; //only one texture
                
                //return min (caustic_one, caustic_two);  // Two combined 
                
                color += min (caustic_one, caustic_two);
                return color;
            }
            ENDCG
        }
    }
}
