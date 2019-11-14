Shader "Silhouete/Silhouete"
{
    Properties
    {
		_Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
		Pass
        {
			Stencil 
            {
                Ref 69
                Comp Equal
            }

			ZTest GEqual	  //to draw only behind walls
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

			float4 _Color;

            fixed4 frag (v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
