// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

// モデルが溶けるような表現をするシェーダー
Shader "Custom/DissolveCustomShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DissolveTex ("DissolveTex (RGB)", 2D) = "white" {}	// マスク画像
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Threshold ("Threshold", Range(0,1)) = 0.0			// モデルの表示を消す・消さないを判定するしきい値
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
		sampler2D _DissolveTex;
		half _Glossiness;
		half _Metallic;
		half _Threshold;
		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
		};

		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 m = tex2D(_DissolveTex, IN.uv_MainTex);

			// マスク画像のUV座標の明度を判定するためモノクロ化(グレースケール化)
			half g = m.r * 0.2 + m.g * 0.7 + m.b * 0.1;

			// 明度がしきい値以下であった場合
			if(g < _Threshold)
			{
				// 処理を破棄(ピクセルを破棄するclipと同等？)
				discard;
			}

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
