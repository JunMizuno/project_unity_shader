// シンプルなアウトラインシェーダー
// @memo. カメラの距離によって太さが変わってしまうため、改良が必要
Shader "Custom/SimpleOutlineShader"
{
	// インスペクター上のUI設定
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_OutlineWidth("Outline Width", float) = 0.05
		_MainColor("Main Color", Color) = (1,1,1,1)
	}

	// アウトライン化のテストシェーダーにテクスチャを追加
	SubShader
	{
		// どちらでも結果変わらず・・・
		Tags 
		{
			//"Queue"="Geometry"
			"RenderType"="Opaque"
		}

		// メインのモデル
		// 先にテクスチャを貼り付けたメインのモデルの描画処理を行わないといけない模様
		Cull Back

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows

		sampler2D _MainTex;
		float4 _MainColor;

		struct Input
		{
			float2 uv_MainTex;
		};

		float _ScrollX;
		float _ScrollY;

		half _Glossiness;
		half _Metallic;

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			float2 scroll = float2(_ScrollX, _ScrollY) * _Time.y;

			fixed4 c = tex2D(_MainTex, IN.uv_MainTex + scroll);

			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}

		ENDCG

		// アウトライン
		Pass
		{
			Cull Front

			CGPROGRAM

			// インクルードファイルの設定
			#include "UnityCG.cginc"

			// DirectXでいうところのテクニック？？
			#pragma vertex vert
			#pragma fragment frag

			// 変数を宣言(値はインスペークターやプロパティから受け取る)
			float4 _OutlineColor;
			float _OutlineWidth;

			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				// カメラからの距離を計算
				float outDist = UnityObjectToViewPos(v.vertex).z;

				// モデルの頂点座標を法線方向に膨らませる
				//v.vertex.xyz += v.normal * (-outDist * _OutlineWidth);
				v.vertex.xyz += v.normal * _OutlineWidth;

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			// アウトラインのカラーをそのまま返す
			fixed4 frag(v2f i) : SV_Target
			{
				return _OutlineColor;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
