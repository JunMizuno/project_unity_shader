// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 紙をめくる演出をつけるシェーダー
Shader "Custom/PageScrollShader"
{
	Properties
	{
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_PageTex ("PageTex (RGB)", 2D) = "white" {}
		_AlphaMask ("AlphaMask", Range(0.0, 1.0)) = 0.1
		_Flip ("Flip", Range(-1, 1)) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct vertInput
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 puv : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _PageTex;
			float4 _PageTex_ST;

			float _AlphaMask;
			float _Flip;

			float l2(float x)
			{
				return 1 - _Flip + 0.1 * cos(x * 2.0);
			}

			float l1(float y)
			{
				return _Flip + 0.1 * sin(y * 3.0);
			}

			float l0(float x)
			{
				return x - _Flip;
			}

			v2f vert(vertInput v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.puv = TRANSFORM_TEX(v.uv, _PageTex);
				return o;
			}

			fixed4 frag(v2f IN) : SV_TARGET
			{
				// メインとページのテクスチャ色を取得
				float4 mainColor = tex2D(_MainTex, IN.uv);
				float4 pageColor = tex2D(_PageTex, IN.puv);

				// L0より右の描画を無視する(ページをめくった部分を破棄する)
				// @memo. l0_y に代入する値を返す関数ないの数値などを変更することで、演出が変わるとのこと
				float l0_y = l0(IN.uv.x);
				clip(IN.uv.y - l0_y);		// clip(x) x < 0 の時にピクセルを破棄する関数

				// 範囲内ならば暗い色にする(ページのめくり部分を表現する)
				// _MainTexの色情報を破棄して設定色に上書きする
				if(IN.uv.x > l1(IN.uv.y) && IN.uv.y < l2(IN.uv.x))
				{
					mainColor = float4(0.5, 0.5, 0.5, 0.5);
				}

				// ページ内容のうち一定の値より透明なものはページの色にすり替える
				if(mainColor.a < _AlphaMask)
				{
					return pageColor;
				}

				return mainColor * pageColor;
			}

			ENDCG
		}
	}
}
