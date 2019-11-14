Shader "Silhouete/StencilPass"
{
    Properties
    {
    }
    SubShader
    {

		Stencil
		{
			Ref 69
			Comp Always
			Pass Replace
		}

        Tags { "Queue" = "Geometry-1" } // Draw before Geometry
        ColorMask 0 // Don't write to any colour channels
		ZWrite Off // Don't write to the Depth buffer
        Pass
        {
        }
    }
}
