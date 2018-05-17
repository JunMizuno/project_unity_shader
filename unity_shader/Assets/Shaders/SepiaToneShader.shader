// セピア調を表現するシェーダー
Shader "Custom/SepiaToneShader"
{
	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {}
		_Darkness("Dark", Range(0, 0.1)) = 0.04
		_Strength("Strength", Range(0.05, 0.15)) = 0.05
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
			float _Strength;

			fixed4 frag(v2f_img i) : COLOR
			{
				fixed4 c = tex2D(_MainTex, i.uv);

				// グレースケール化に合わせて明度も調整
				half gray = c.r * 0.3 + c.g * 0.6 + c.b * 0.1 - _Darkness;
				gray = (gray < 0) ? 0 : gray;		// マイナス値にならないように補正

				// セピア調なのでRとBのみ調整(赤成分を足して青成分を減らす)
				half R = gray + _Strength;
				half B = gray - _Strength;

				R = (R > 1.0) ? 1.0 : R;			// 1.0を超えないように補正
				B = (B < 0) ? 0 : B;				// マイナス値にならないように補正
				c.rgb = fixed3(R, gray, B);

				return c;
			}

			ENDCG
		}
	}
}
