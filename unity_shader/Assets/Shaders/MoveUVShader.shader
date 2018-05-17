// UV座標を移動させて参照テクスチャを動かすように見せるシェーダー
// ベースのサーフェイスシェーダーのsurf関数のみを少し改修したもの
Shader "Custom/MoveUVShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_ScrollX ("ScrollX", Range(0.0, 3.0)) = 0.1
		_ScrollY ("ScrollY", Range(0.0, 3.0)) = 0.1
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		fixed4 _Color;
		sampler2D _MainTex;
		half _Glossiness;
		half _Metallic;

		float _ScrollX;
		float _ScrollY;

		struct Input
		{
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// スクロール距離の計算(ここでは定義値_Timeの当倍速を使用)
			float2 scroll = float2(_ScrollX, _ScrollY) * _Time.y;

			// インスペクターで設定されているテクスチャとそのUV座標を取得して、テクスチャ上のピクセルの色を計算する
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex + scroll) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}

	// 実行失敗時などに参照するシェーダーの設定
	FallBack "Diffuse"
}
