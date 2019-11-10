Shader "Presentation/Dissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("_NoiseTex", 2D) = "white" {}
		_DissolveFactor("DissolveFactor", Float) = 0.5
		[HDR]_ColorEdge("ColorEdge", Color) = (1,1,1,1)
		_Moved("Moved", Float) = 0.5
		_Power("Power", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Tranparent" }
        LOD 100

        Pass
        {
			//Zwrite On
			//Cull Off // we want the front and back faces
			//AlphaToMask On // transparency
			Blend SrcAlpha OneMinusSrcAlpha

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
			
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;

			float _DissolveFactor;
			float4 _ColorEdge;
			float _Moved;
			float _Power;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 alpha = tex2D(_NoiseTex, i.uv);

				clip(alpha.r - abs(_SinTime.w)); // _DissolveFactor if you want to controll from outside
                
                // Just base texture
                //return col;
                
				float moved_alpha = alpha.r - abs(_SinTime.w) - _Moved;
				float clamp = saturate(moved_alpha);
				float power = pow(clamp, _Power);

                //return lerp(float4(0,0,0,0), _ColorEdge.rgba, 1 - power);

				col.rgb = lerp(col.rgb, _ColorEdge.rgb, 1 - power);
				

                return col;
            }
            ENDCG
        }
    }
}
