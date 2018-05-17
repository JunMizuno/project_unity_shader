// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// ラスタースクロールシェーダー(画面全体のエフェクト用)
// PostEffect.csと合わせてMainCameraにアタッチして使用
Shader "Custom/RasterScrollShader"
{
	Properties
	{
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_Level ("Level", Range(0.0, 1.0)) = 0.2
		_Speed ("Speed", Range(0.0, 3.0)) = 0.5
		_RoundTrip ("RoundTrip", Range(1.0, 5.0)) = 1.0
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert			// 頂点シェーダー
			#pragma fragment frag		// フラグメントシェーダー

			#include "UnityCG.cginc"	// ライブラリをインクルード

			struct vertInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;		// マクロ内で使用しているため宣言のみ行う
			float _Level;
			float _Speed;
			float _RoundTrip;

			// 頂点シェーダー
			v2f vert(vertInput v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);		// 座標変換
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);		// UV座標取得
				return o;
			}

			// フラグメントシェーダー
			float4 frag(v2f IN) : COLOR
			{
				// 1秒で_Speedずつ加算される値の作成
				float time = _Time.y * _Speed;

				// Y座標(0〜1)における波形のスタート位置のズレ
				float dy = time - floor(time);		// floorは小数点切り捨て

				// 同様に、X座標(0〜1)のズレ
				float dx = sin(radians((IN.uv.y - dy) * 360.0 * floor(_RoundTrip))) * _Level;

				// ピクセルの位置を計算
				float2 uv = float2(IN.uv.x + dx, IN.uv.y);

				// X座標が範囲外になっているものは塗りつぶす(ここでは黒に)
				// 画面外にはみ出した演出をしない場合はclipやdiscardを使用すること
				if(uv.x < 0 || 1 < uv.x)
				{
					return float4(0.0, 0.0, 0.0, 0.0);
				}

				// 最終的に計算したUV座標からピクセルの色を取得
				float4 lastedColor = tex2D(_MainTex, uv);

				return lastedColor;
			}

			ENDCG
		}
	}
}
