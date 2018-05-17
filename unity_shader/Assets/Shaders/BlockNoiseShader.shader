// ブロックのノイズがかかったような表現をするシェーダー
Shader "Custom/BlockNoiseShader"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_NoiseBlocks ("NoiseBlocks", Int) = 8			// ノイズ生成時のブロックの数(値を大幅にあげれば砂嵐も表現可能)
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent" 
			"RenderType"="Opaque"
		}

		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert alpha
		#pragma target 3.0

		sampler2D _MainTex;
		fixed4 _Color;
		int _NoiseBlocks;

		struct Input
		{
			float2 uv_MainTex;
		};

		// ランダム値を生成
		float random(fixed2 p)
		{
			return frac(sin(dot(p, fixed2(12.9898, 78.233))) * 43758.5453);
		}

		float noise(fixed2 st)
		{
			fixed2 p = floor(st);
			return random(p);
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			float c = noise(IN.uv_MainTex * _NoiseBlocks);		// _NoiseBlocksでノイズサイズをコントロールできる模様(_NoiseBlocks x _NoiseBlocksのブロックノイズを生成して、その中からランダムに1点を抽出している)
			o.Albedo = fixed3(c, c, c);
			o.Alpha = 1;
		}

		ENDCG
	}

	//FallBack "Diffuse"
}
