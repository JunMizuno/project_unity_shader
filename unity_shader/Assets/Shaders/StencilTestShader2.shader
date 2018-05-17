// ステンシルバッファを用いた描画のシェーダー(背面及び合成用)
// StencilTestShader1と組み合わせて使用する
Shader "Custom/StencilTestShader2"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue"="Transparent"
			"IgnoreProjector"="True"
		}

		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

		// 1つ目の描画処理
		Pass
		{
			// ステンシルバッファが1のところのみ描画するように設定
			Stencil
			{
				Ref 1
				Comp Equal
			}
										
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;

			fixed4 frag(v2f_img IN) : SV_TARGET
			{
				// ステンシルバッファが対象の値になっている箇所かつUV座標の該当する部分のみ黒く塗る
				float alpha = tex2D(_MainTex, IN.uv).a;
				fixed4 c = fixed4(0, 0, 0, alpha);
				return c;
			}

			ENDCG
		}

		// 2つ目の描画処理
		Pass
		{
			// ステンシルバッファが0のところのみ描画するように設定
			Stencil
			{
				Ref 0
				Comp Equal
			}

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;

			fixed4 frag(v2f_img IN) : SV_TARGET
			{
				// ステンシルバッファが対象の値になっている箇所かつUV座標の該当する部分のみメインテクスチャを描画
				fixed4 c = tex2D(_MainTex, IN.uv);
				return c;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
