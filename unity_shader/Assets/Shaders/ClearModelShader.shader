// モデルを半透明にするシェーダー
Shader "Custom/ClearModelShader"
{
	Properties
	{
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Alpha ("Alpha", Range(0.1,15.0)) = 1.5
	}

	SubShader
	{
		Tags
		{
			// 透明化する際に設定追加
			"Queue"="Transparent"
			//"RenderType"="Transparent"
		}

		LOD 200

		CGPROGRAM
		#pragma surface surf Standard alpha:fade		// 透明化する際に設定追加
		#pragma target 3.0

		sampler2D _MainTex;
		fixed4 _Color;
		float _Alpha;

		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			o.Albedo = fixed4(c.r, c.g, c.b, c.a);

			// 内積を使用して、カメラのビューベクトルとモデルの法線が交わるところのアルファ値がゼロに近くなるように計算している
			float alpha = 1 - (abs(dot(IN.viewDir, IN.worldNormal)));

			o.Alpha = alpha * _Alpha;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
