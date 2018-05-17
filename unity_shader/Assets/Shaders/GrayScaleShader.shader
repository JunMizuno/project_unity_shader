// グレースケール化シェーダー
Shader "Custom/GrayScaleShader"
{
	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {}
		_Darkness("Dark", Range(0, 0.1)) = 0.04		// 明るさ調整
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _Darkness;

			fixed4 frag(v2f_img i) : COLOR
			{
				// メインテクスチャの色を取得
				fixed4 c = tex2D(_MainTex, i.uv);

				// グレースケール化に合わせて明度も調整
				half gray = c.r * 0.3 + c.g * 0.6 + c.b * 0.1 - _Darkness;
				gray = (gray < 0) ? 0 : gray;		// マイナス値にならないように補正

				return gray;
			}

			ENDCG
		}
	}
}
