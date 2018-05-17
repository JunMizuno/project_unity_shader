// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 背景などのリピートスクロールシェーダー
// スクリプト側からオフセットの値(ターゲットのポジションとスクロールスピードを足したもの)を受け取る必要あり
Shader "Custom/RepeatScrollShader"
{
	Properties
	{
		[NoScaleOffset]
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_OffsetX ("OffsetX", Float) = 0.0
		_OffsetY ("OffsetY", Float) = 0.0
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

			sampler2D _MainTex;
			float4 _MainTex_ST;		// マクロ内で使用しているので宣言のみ
			float _OffsetX;
			float _OffsetY;

			struct vertInput
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			// 頂点シェーダー
			v2f vert(vertInput v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			// フラグメントシェーダー
			fixed4 frag(v2f IN) : SV_TARGET
			{
				// オフセット + UV値を(0〜1)でリピート
				float2 uv = float2(abs(fmod(IN.uv.x + _OffsetX, 1.0)), abs(fmod(IN.uv.y + _OffsetY, 1.0)));

				fixed4 color = tex2D(_MainTex, uv);

				return color;
			}

			ENDCG
		}
	}
}
