// ぼかしノイズシェーダー
Shader "Custom/ValueNoise"
{
	Properties
	{
		_MainTex ("BaseTexture (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_NoiseBlocks ("NoiseBlocks", Int) = 8
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
		float _NoiseBlocks;

		struct Input
		{
			float2 uv_MainTex;
		};

		// GPUに依存せずにランダム値をシェーダー内で取得する計算式
		float random(fixed2 p)
		{
			return frac(sin(dot(p, fixed2(12.9898, 78.223))) * 43758.5453);
		}

		float noise(fixed2 st)
		{
			fixed2 p = floor(st);
			return random(p);
		}

		float valueNoise(fixed2 st)
		{
			fixed2 p = floor(st);						// ピクセルの基本座標(数値の整数値部分)
			fixed2 f = frac(st);						// ピクセルのオフセット(数値の小数点部分)(pの座標からさらにどの座標かを取得するために使用)

			float v00 = random(p + fixed2(0, 0));		// ピクセルの左下
			float v10 = random(p + fixed2(1, 0));		// ピクセルの右下
			float v01 = random(p + fixed2(0, 1));		// ピクセルの左上
			float v11 = random(p + fixed2(1, 1));		// ピクセルの右上

			fixed2 u = f * f * (3.0 - 2.0 * f);			// -2fの3べき乗 + 3fの2べき乗(0〜1の間の値をsin波のようにゆるやかに計測)

			float v0010 = lerp(v00, v10, u.x);			// ピクセルの左下と右下の中間の色をuで定めたX座標の補正値を絡めて設定する
			float v0111 = lerp(v01, v11, u.x);			// ピクセルの左上と右上の中間の色をuで定めたX座標の補正値を絡めて設定する

			return lerp(v0010, v0111, u.y);				// 上記2点の中間の色をuで定めたY座標の補正値を絡めて設定する
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			float c = valueNoise(IN.uv_MainTex * _NoiseBlocks);
			o.Albedo = fixed3(c, c, c);
			o.Alpha = 1.0;
		}

		ENDCG
	}

	//FallBack "Diffuse"
}
