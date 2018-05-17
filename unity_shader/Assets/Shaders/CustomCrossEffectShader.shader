// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// テクスチャを重ね合わせてそれぞれにマスクをかけるシェーダー
Shader "Custom/CustomCrossEffectShader"
{
	Properties
	{
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_MaskTex ("MaskTex (RGB)", 2D) = "white" {}
		//_BlendTex ("BlendTex (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)

		// マスクをかける値
		_MaskValue ("MaskValue", Range(0.0, 5.0)) = 0.0

		_CrossTex ("CrossTex (RGB)", 2D) = "black" {}
		_Level ("Level", Range(0.0, 1.0)) = 0.2
		_Speed ("Speed", Range(0.0, 3.0)) = 0.5
		_RoundTrip ("RoundTrip", Range(1.0, 5.0)) = 1.0
	}

	SubShader 
	{
		// 透過度を有効にする
		Blend SrcAlpha OneMinusSrcAlpha

		Tags
		{
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}

		// 1つ目の描画
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _MaskTex;
			//sampler2D _BlendTex;
			float4 _Color;

			// マスクをかける値
			float _MaskValue;

			struct vertInput
			{
				float4 vertex : POSITION;			// 座標
				float2 uv : TEXCOORD0;				// UV座標
				float3 normal : NORMAL;				// 法線
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 muv : TEXCOORD1;				// マスクテクスチャ用
				//float2 buv : TEXCOORD2;				// ブレンドテクスチャ用
			};

			// 頂点シェーダー
			v2f vert(vertInput v)
			{
				//float4 maskTex = tex2Dlod(_MaskTex, float4(v.uv.xy, 0.0, 0.0));

				v2f o;
				//o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.muv = v.uv;
				//o.buv = v.uv;
				return o;
			}

			// フラグメントシェーダー
			fixed4 frag(v2f IN) : SV_TARGET
			{
				fixed4 mainColor = tex2D(_MainTex, IN.uv);
				//fixed4 blendColor = tex2D(_BlendTex, IN.buv);

				fixed4 maskColor = tex2D(_MaskTex, IN.muv);

				// マスクの値によってピクセルを破棄する
				float check = maskColor.r + maskColor.g + maskColor.b;
				clip(check - _MaskValue);

				//fixed4 fixedColor = mainColor * blendColor * _Color;
				fixed4 fixedColor = mainColor * _Color;

				return fixedColor;
			}

			ENDCG
		}

		// 2つ目の描画
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _CrossTex;
			float _Speed;
			float _Level;
			float _RoundTrip;

			sampler2D _MaskTex;
			float _MaskValue;

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
			float4 frag(v2f IN) : COLOR
			{
				// マスクをかけるテクスチャの色を取得
				float4 maskColor = tex2D(_MaskTex, IN.uv);

				// マスクの値によってピクセルを破棄する
				float check = maskColor.r + maskColor.g + maskColor.b;
				clip(check - _MaskValue);

				// 1秒で_Speedずつ加算される値の作成
				float time = _Time.y * _Speed;

				// Y座標(0〜1)における波形のスタート位置のズレ
				float dy = time - floor(time);

				// 同様に、X座標(0〜1)のズレ
				float dx = sin(radians((IN.uv.y - dy) * 360.0 * floor(_RoundTrip))) * _Level;

				// ピクセルの位置を計算
				float2 uv = float2(IN.uv.x + dx, IN.uv.y);

				// X座標が範囲外になっているものはピクセルを破棄する(表示させないようにする)
				if(uv.x < 0 || 1 < uv.x)
				{
					discard;
				}

				// ベーステクスチャの色を取得
				float4 crossColor = tex2D(_CrossTex, uv);

				return crossColor;
			}

			ENDCG
		}
	}
}
