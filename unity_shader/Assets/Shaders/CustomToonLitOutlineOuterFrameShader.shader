// ステンシルテスト＋白枠＋影描画＋アウトライン
// CustomToon〜のシェーダーからそれぞれの処理を組み合わせたもの、それぞれのシェーダーファイル必須
Shader "Custom/CustomToonLitOutlineOuterFrameShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_RampTex ("RampTex (RGB)", 2D) = "gray" {}
		[Enum(OFF, 0, FRONT, 1, BACK, 2)] _CullMode("Cull Mode", int) = 2		// OFF、FRONT、BACKを設定
		_StencilRefMain ("StencilRefMain", Range(0, 255)) = 128
		_StencilRefOuterFrame ("StencilRefOuterFrame", Range(0, 255)) = 112
		_StencilRefShadow ("StencilRefShadow", Range(0, 255)) = 96
		_OuterFrameColor ("OutrFrameColor", Color) = (1,1,1,1)
		_OuterFrameWidth ("OuterFrameWidth", Range(0.0, 1.0)) = 0.02
		_OuterShadowColor ("OuterShadowColor", Color) = (0.5, 0.5, 0.5, 0.5)
		_OuterShadowOffset ("OuterShadowOffset", Vector) = (-0.5, -0.5, 0.0)
		_OutlineColor ("OutlineColor", Color) = (0,0,0,1)
		_OutlineWidth ("OutlineWidth", Range(0.001, 0.03)) = 0.005
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		// 各シェーダーファイルから処理を抜粋して実行
		UsePass "Custom/CustomToonLitShader/FORWARD"
		UsePass "Custom/CustomToonLitOutlineShader/OUTLINE"
		UsePass "Custom/CustomToonLitOuterFrameShader/OUTER FRAME"
		UsePass "Custom/CustomToonLitOuterFrameShader/OUTER SHADOW"
	}

	FallBack "Custom/CustomToonLitShader"
}
