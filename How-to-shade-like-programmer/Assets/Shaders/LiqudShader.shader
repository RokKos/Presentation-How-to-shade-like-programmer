Shader "Presentation/LiqudShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_FillAmount("Fill Amount", Range(-10,10)) = 0.0
		_Tint("Tint", Color) = (1,1,1,1)
		_RimPower("Rim Power", Range(0,10)) = 0.0
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_FoamSize("Foam Line Width", Range(0,0.1)) = 0.0
		_FoamColor("Foam Line Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue" = "Geometry"  "DisableBatching" = "True" }
        LOD 100

        Pass
        {

			Zwrite On
			Cull Off // we want the front and back faces
			AlphaToMask On // transparency

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
                float4 vertex : SV_POSITION;
				float3 viewDir : COLOR;
				float3 normal : COLOR2;
				float fillEdge : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float4 _Tint;

			float _FillAmount;

			float _RimPower;
			float4 _RimColor;

			float _FoamSize;
			float4 _FoamColor;

			float4 RotateAroundYInDegrees(float4 vertex, float degrees)
			{
				float alpha = degrees * UNITY_PI / 180;
				float sina, cosa;
				sincos(alpha, sina, cosa);
				float2x2 m = float2x2(cosa, sina, -sina, cosa);
				return float4(vertex.yz, mul(m, vertex.xz)).xzyw;
			}


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex.xyz);
				// rotate it around XY
				float3 worldPosX = RotateAroundYInDegrees(float4(worldPos, 0), 360);
				// rotate around XZ
				float3 worldPosZ = float3 (worldPosX.y, worldPosX.z, worldPosX.x);
				// combine rotations with worldPos, based on sine wave from script
				float3 worldPosAdjusted = worldPos + (worldPosX  * _SinTime.w) + (worldPosZ* _SinTime.w);

				// how high up the liquid is
				o.fillEdge = worldPosAdjusted.y + _FillAmount;

				o.viewDir = normalize(ObjSpaceViewDir(v.vertex));
				o.normal = v.normal;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col_with_tint = col * _Tint;

				//return col_with_tint;


				// Rim light
				float dotProduct = dot(i.normal, i.viewDir);
				float dotEnhanced = pow(dotProduct, _RimPower);
				float inverseDot = 1 - dotEnhanced;
                //return inverseDot;

				float clamped_rim = clamp(inverseDot, 0.5, 1.0);

				float4 rim_color = clamped_rim * _RimColor;
				//return rim_color;


				// foam on top
				float4 foam = step(i.fillEdge, 0.5) - step(i.fillEdge, (0.5 - _FoamSize));
				float4 foam_part = foam * _FoamColor;
				//return foam_part;

				float4 result = step(i.fillEdge, 0.5) - foam;
				float4 main_liquid = result * col_with_tint;
				//return main_liquid;

				float4 whole_liquid = main_liquid + foam_part;
				//return whole_liquid;

				float4 final_result = whole_liquid;
				final_result.rgb += rim_color;

				return final_result;




            }
            ENDCG
        }
    }
}
