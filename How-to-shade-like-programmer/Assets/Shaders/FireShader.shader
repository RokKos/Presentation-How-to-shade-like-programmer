	Shader "Presentation/FireShader"
{
    Properties
    {
		_FireColor("Fire Color", Color) = (1,1,1,1)
		_NoiseTex("_NoiseTex", 2D) = "white" {}
		_GradientTex("_GradientTex", 2D) = "white" {}
		_NoiseFactor("_NoiseFactor", Float) = 0.5
		_Radius("_Radius", Float) = 0.5
		_Hardness("_Hardness", Float) = 0.5
		_Center("_Center", Float) = 0.5
		_WoblyScale("_WoblyScale", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		
			Blend SrcAlpha OneMinusSrcAlpha // Traditional transparency

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
				float2 grad_uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
			};
			
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			sampler2D _GradientTex;
			float4 _GradientTex_ST;
			float _NoiseSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.grad_uv = TRANSFORM_TEX(v.uv, _GradientTex);
                return o;
            }
			
			float4 _FireColor;
			float _NoiseFactor;
			float _Radius;
			float _Hardness; 
			float _Center;
			float _WoblyScale;

			void Unity_SphereMask_float4(float4 Coords, float4 Center, float Radius, float Hardness, out float4 Out)
			{
				Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
			}

            fixed4 frag (v2f i) : SV_Target
            {
				// Coments are just examples

				fixed4 col = _FireColor;
				
				fixed noise = tex2D(_NoiseTex, i.uv).r;
				//clip(noise - _NoiseFactor);
				//return col;
				
				fixed gradient = tex2D(_GradientTex, i.grad_uv).r;
				gradient = 1 - gradient;

				clip(noise - _NoiseFactor * gradient);
				//return col;

				col.g *= 1.0 + gradient + gradient * noise;
				//return col;

				
				//float normalDistance = 1 - distance(float4(_Center, _Center, 0, 0), float4(i.uv, 0, 0) - _Radius);
				//return float4(normalDistance, normalDistance, normalDistance, 1);
				
				//float sineDistance = distance(float4(sin(_Time.z + _Center), _Center, 0, 0), float4(i.uv, 0, 0) - _Radius);
				//return float4(sineDistance, sineDistance, sineDistance, 1);
				
				//float sineGradDistance = distance(float4(sin(_Time.z + _Center) * gradient, _Center, 0, 0), float4(i.uv, 0, 0) - _Radius);
				//return float4(sineGradDistance, sineGradDistance, sineGradDistance, 1);
				
				float4 mask;  // Circle mask
				float centerX = 0.5 + gradient * sin(_Time.z + _Center) * noise * _WoblyScale;
				float4 fire_center = float4(centerX, _Center, 0, 0);
				
				Unity_SphereMask_float4(float4(i.uv, 0, 0), fire_center, _Radius, _Hardness, mask);
				//return mask;
				col.a = mask.r;

                return col;
            }
            ENDCG
        }
    }
}
