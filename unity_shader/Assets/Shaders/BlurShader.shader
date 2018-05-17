// ブラーシェーダー(PostEffect.csと組み合わせてMainCameraに組み込んで使用する)
Shader "Custom/BlurShader"
{
	Properties
	{
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_Diff ("Diff", Float) = 0.0
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img		// 標準のものを使用するため宣言のみ
			#pragma fragment frag		// フラグメントシェーダーのみカスタム

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _Diff;

			float4 frag(v2f_img IN) : COLOR
			{
				// それぞれ左右にズレたピクセルを重ね合わせるイメージ
				float4 c = tex2D(_MainTex, IN.uv - _Diff) + tex2D(_MainTex, IN.uv + _Diff);

				// それを半分にすることで、ちょうど1枚(1ピクセル)分の色合いとなるイメージ
				return c / 2.0;
			}

			ENDCG
		}
	}
}
