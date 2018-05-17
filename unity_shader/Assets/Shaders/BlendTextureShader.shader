// 2枚のテクスチャをマスク画像の影響度によってブレンドするシェーダー
Shader "Custom/BlendTextureShader"
{
	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {}		// メインのテクスチャ
		_SubTex ("SubTex", 2D) = "white" {}			// 上乗せする画像
		_MaskTex ("MaskTex", 2D) = "white" {}		// マスクをかける画像(しきい値の役割を果たす)
		_Color ("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _SubTex;
		sampler2D _MaskTex;
		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
		};

		// サーフェイスシェーダー
		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			// それぞれのカラーを取得
			fixed4 mainTexColor = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 subTexColor = tex2D(_SubTex, IN.uv_MainTex);
			fixed4 maskTexColor = tex2D(_MaskTex, IN.uv_MainTex);

			// cの値によって、aとbの中間の値を取得
			// _MainTexの上に_SubTexをかぶせるイメージ
			o.Albedo = lerp(mainTexColor, subTexColor, maskTexColor);
		}

		ENDCG
	}

	FallBack "Diffuse"
}
