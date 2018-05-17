// ステンシルバッファを用いた描画のシェーダー(前面用)
// StencilTestShader2と組み合わせて使用する
Shader "Custom/StencilTestShader1"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}

	SubShader
	{
		Tags 
		{
			"RenderType"="Opaque"
		}

		LOD 200

		Pass
		{
			// ここでは「Comp Always」と「Pass Replace」で、描画する位置は常に強制的にステンシルバッファが1となるようにしている
			Stencil
			{
				Ref 1				// ステンシルに1の値を書き込む(ステンシル値の設定)
				Comp Always			// 使用する比較関数
				Pass Replace		// 比較関数が真のときの操作
			}

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;

			fixed4 frag(v2f_img IN) : COLOR
			{
				fixed4 c = tex2D(_MainTex, IN.uv);
				return c;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
