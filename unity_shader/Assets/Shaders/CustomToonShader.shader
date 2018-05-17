// オリジナルのトゥーンシェーダー(ウェブ参照版)
Shader "Custom/CustomToonShader"
{
	Properties
	{
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_RampTex ("Ramp (RGB)", 2D) = "white" {}		// 矩形(長方形)で[明るい・普通・暗い]場合に描画するマップテクスチャを設定する
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
		#pragma surface surf ToonRamp		// LightingXXという名称でライティング処理をフックする関数を設定する
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _RampTex;
		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
		};

		// ライティング処理をフックする関数
		fixed4 LightingToonRamp(SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
			half d = dot(s.Normal, lightDir) * 0.5 + 0.5;
			fixed3 ramp = tex2D(_RampTex, fixed2(d, 0.5)).rgb;		// ライトの当たる強さ(明るさ)によって_RampTexから取得する色を変化させる
			fixed4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp;
			c.a = 0;
			return c;
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
