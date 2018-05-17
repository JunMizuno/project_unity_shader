// シンプルなマスクシェーダー
Shader "Custom/TestMyShader1"
{
	Properties
	{
		// デフォルト
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_MaskTex ("MaskTex (RGB)", 2D) = "white" {}
		_DiscardValue ("DiscardValue", Range(0.0, 1.0)) = 1.0		// 不可視にするしきい値
	}

	SubShader
	{
		Pass
		{
			// 以下、透過を有効にする組み合わせ
			Tags
			{
				"Queue"="Transparent"			// オブジェクトを描画させる順番を設定
				"RenderType"="Transparent"		// ほとんどの部分的に透過なシェーダーとする設定
			}

			//Blend SrcAlpha OneMinusSrcAlpha
			//Blend One OneMinusSrcAlpha
			Blend SrcAlpha OneMinusSrcAlpha		// アルファブレンドを設定

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			// メインのテクスチャ
			sampler2D _MainTex;

			// マスクをかけるテクスチャ
			sampler2D _MaskTex;

			//※テスト
			float3 _PrevColor;
			float3 _PrevPrevColor;

			// 不可視にするしきい値
			float _DiscardValue;

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
				o.uv = v.uv;
				return o;
			}

			// フラグメントシェーダー
			fixed4 frag(v2f IN) : SV_TARGET
			{
				fixed4 c = tex2D(_MainTex, IN.uv);

				fixed4 maskColor = tex2D(_MaskTex, IN.uv);

				// マスクをかける画像をグレースケール化する
				float gray = maskColor.r * 0.6 + maskColor.g * 0.3 + maskColor.b * 0.1;

				// その値がしきい値よりも小さかった場合(より黒に近かった場合)
				if(gray < _DiscardValue)
				{
					// 透過あるいはピクセル破棄とする
					c = fixed4(c.r, c.g, c.b, 0.5);
					//discard;
				}

				return c;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
