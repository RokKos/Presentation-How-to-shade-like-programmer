Shader "Presentation/Hologram"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_OffsetScale("OffsetScale", Float) = 30
		_DistortPow("Distort Power", Float) = 2
		_DistortSpeed("Distort Speed", Float) = 0.5
		_FresnelPow("FresnelPow", Float) = 0.5
    }
    SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
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
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD2;
            };

            
			float4 _Color;
			float _OffsetScale;
			float _DistortPow;
			float _DistortSpeed;
			float _FresnelPow;
			
			float Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power) {
				return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
			}


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				o.normal = v.normal;
				o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //return float4(i.worldPos, 1.0f); // -> Wordl pos

				float y_pos = i.worldPos.y;
				float y_offset = (y_pos + _Time.y) * _OffsetScale;
				float straight_line = saturate(sin(y_offset));

				//return float4(straight_line, straight_line, straight_line, 1.0f); // -> Line

				float distorted_line = frac((y_offset / _OffsetScale) * _DistortSpeed);
				distorted_line = pow(distorted_line, _DistortPow);
				//return distorted_line;

				float final_line = straight_line + distorted_line;
				float4 line_col = float4(final_line, final_line, final_line, final_line);
				//return line_col;

				float fresnel_efect = Unity_FresnelEffect_float(i.normal, i.viewDir, _FresnelPow);
				//return float4(fresnel_efect, fresnel_efect, fresnel_efect, fresnel_efect);


				float line_with_fresnel = final_line + fresnel_efect;
				//return float4(line_with_fresnel, line_with_fresnel, line_with_fresnel, line_with_fresnel);
				
				float4 final_color = float4(line_with_fresnel * _Color.r, line_with_fresnel *_Color.g, line_with_fresnel * _Color.b, line_with_fresnel);
				return final_color;

            }
            ENDCG
        }
    }
}
