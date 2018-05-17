// シンプルなサーファイスシェーダー
Shader "Custom/SimpleSurfaceShader"
{
	Properties
	{
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags
		{
			// 透過フェーズで描画させる設定
			"Queue"="Transparent"
		}

		// ファーストPass
		// カリングフロント
		Cull Front

		CGPROGRAM
		// Lambert:ランバート(ライティング)、alpha:透過度有効
		#pragma surface surf Lambert alpha

		sampler2D _MainTex;

		struct Input
		{
			float2 uv_MainTex;
			float4 vtxColor : COLOR;
		};

		float4 _Color;

		void surf (Input IN, inout SurfaceOutput o)
		{
			// カラーバーの値を反映させるため、プロパティのカラー値を最後に掛け合わせています
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG

		// セカンドPass
		// カリングバック
		Cull Back

		CGPROGRAM
		#pragma surface surf Lambert alpha

		sampler2D _MainTex;

		struct Input
		{
			float2 uv_MainTex;
			float4 vtxColor : COLOR;	
		};

		float4 _Color;

		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}

	// エラーなどあった際に最終的に採用するデフォルトのシェーダー設定
	//FallBack "Diffuse"
}
