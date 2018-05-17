// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 再生時にモザイク処理がかかるシェーダー
Shader "Custom/MosaicShader"
{
	// インスペクター上のプロパティ
	Properties
	{
		// 設定された画像がここに入る
		_MainTex ("Texture", 2D) = "white" {}
		_Size ("Size", float) = 1
	}

	//モザイク処理のテストシェーダー
	SubShader
	{
		// 不要な機能はオフにする
		Cull Off
		//ZWrite Off
		ZTest Always

		Fog { Mode Off }

		Pass
		{
			// シェーダープログラムの本体
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			v2f vert (appdata_img v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.texcoord.xy);
				return o;
			}
			
			sampler2D _MainTex;
			float _Size;

			fixed4 frag (v2f i) : SV_Target
			{
				// _ScreenParamsは定義済みの値
				// _Size変数の中身を変化させるため、_Timeの値を使って変化させています
				// UV座標(0,0)から中心点を取るために0.5ずらしていると思われる
				float2 delta = (_Size * _Time.a) / _ScreenParams.xy;
				float2 uv = (floor(i.uv / delta) + 0.5) * delta;
				return tex2D(_MainTex, uv);

				// デフォルトの処理x(色を反転させているだけ？)
//				fixed4 col = tex2D(_MainTex, i.uv);
//				col = 1 - col;
//				return col;
			}
			ENDCG
		}
	}
}