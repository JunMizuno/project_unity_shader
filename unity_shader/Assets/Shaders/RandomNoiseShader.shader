// 砂嵐画面シェーダー
Shader "Custom/RandomNoise"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
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

		struct Input
		{
			float2 uv_MainTex;
		};

		float random(fixed2 p)
		{
			return frac(sin(dot(p, fixed2(12.9898, 78.233))) * 43758.5453);
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float rnd = random(IN.uv_MainTex);
			o.Albedo = fixed4(rnd, rnd, rnd, 1);
		}

		ENDCG
	}
}
