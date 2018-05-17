// 深度バッファを描画するシェーダー
// 値取得などのテストケース用、一般描画には使用しない
Shader "Custom/RenderDepthShader"
{
	Properties
	{

	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 depth : TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_DEPTH(o.depth);
				return o;
			}

			half4 frag(v2f IN) : COLOR
			{
				UNITY_OUTPUT_DEPTH(IN.depth);
			}

			ENDCG
		}
	}
}
