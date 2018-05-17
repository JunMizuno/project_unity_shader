// ポストエフェクトでサークルフェードアウトするシェーダー
// PostEffect.csと合わせてMainCameraにアタッチして使用
// @memo. 現時点では画面中央からしかフェードアウトしないので、位置を指定したい場合は改良が必要
Shader "Custom/WipeCircleShader"
{
	SubShader
	{
		Pass
		{		
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _Radius;
			float _WidthAspect;
			float _HeightAspect;

			fixed4 frag(v2f_img IN) : COLOR
			{
				// そのままだと画面左上がアンカーポイントとなって計算されるため、原点を中心とするためにUV座標をずらす
				IN.uv -= fixed2(0.5, 0.5);

				// アスペクト比の補正をかける(UV座標は0.0〜1.0の範囲で表現されるため、そのままだと正円が描けないため)
				IN.uv.x *= _WidthAspect / _HeightAspect;

				// 設定された半径以下の場合はポストエフェクトを掛けずにそのままの画像を表示する
				if(distance(IN.uv, fixed2(0.0, 0.0)) < _Radius)
				{	
					// 処理を破棄
					discard;
				}

				// 黒く塗りつぶす
				return fixed4(0.0, 0.0, 0.0, 1.0);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
