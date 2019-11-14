Shader "BadCops/Laser"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "white" {}
		_NoiseTex("Noise Texture", 2D) = "white" {}
		[HDR]_HighlightColor("Highlight Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_LaserSpeed("Laser Speed", Float) = 2
		_NoiseSpeed("Noise Speed", Float) = 2
		_NoisePower("Noise Power", Float) = 2
		_NoiseAmount("Noise Amount", Float) = 0.5
    }
    SubShader
    {
		Tags {"Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

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
				float4 vertexColor : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float2 uvNoise : TEXCOORD1;
                float4 vertex : SV_POSITION;
				float4 vertexColor : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;

			float4 _HighlightColor;
			float _LaserSpeed;
			float _NoiseSpeed;
			float _NoisePower;
			float _NoiseAmount;
			

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertexColor = v.vertexColor;
                
				float2 originalUv = TRANSFORM_TEX(v.uv, _MainTex);

				o.uvNoise = originalUv + float2(_Time.x * _NoiseSpeed, 0);
				float4 noiseTex = tex2Dlod(_NoiseTex, float4(o.uvNoise, 0, 0));
				noiseTex = pow(noiseTex, _NoisePower);

				o.uv = lerp(originalUv, noiseTex.xy, _NoiseAmount);
				o.uv.x += _Time.x *  _LaserSpeed;
				
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 texCol = tex2D(_MainTex, i.uv);
				texCol.a *= tex2D(_MaskTex, i.uv).r;
				texCol.a *= tex2D(_NoiseTex, i.uvNoise).r;
				
				fixed4 mainCol = texCol * i.vertexColor * _HighlightColor;
                return mainCol;
            }
            ENDCG
        }
    }
}

