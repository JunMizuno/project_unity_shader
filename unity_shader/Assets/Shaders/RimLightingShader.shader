// リムライティング(モデルの背後からの光源を強く見せる)シェーダー
Shader "Custom/RimLightingShader"
{
	Properties
	{
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)						// モデルのコントロールカラー
		_RimColor ("RimColor", Color) = (0.8, 0.7, 0.8, 1.0)	// リムのコントロールカラー
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard
		#pragma target 3.0

		sampler2D _MainTex;
		fixed4 _Color;
		fixed4 _RimColor;

		struct Input
		{
			float2 uv_MainTex;
			float3 worldNormal;
			float3 viewDir;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// モデルのカラーを取得
			fixed4 baseColor = tex2D(_MainTex, IN.uv_MainTex);

			// 縁の光沢を表現する部分の色設定
			fixed4 rimColor = _RimColor;

			o.Albedo = baseColor * _Color;

			// 内積の絶対値を取る(ベクトルが水平に交わる場合はゼロ、垂直の場合は1または-1に近くなるため)
			float rim = 1 - saturate(dot(IN.viewDir, o.Normal));

			// モデルの縁となる部分(光源が水平に当たっている部分)の色を強める(表面から放出される光色と強度)
			// powで自乗する(この場合は2.5〜3.0が一番見栄えが良い)
			o.Emission = rimColor * pow(rim, 3.0);
		}

		ENDCG
	}

	FallBack "Diffuse"
}
