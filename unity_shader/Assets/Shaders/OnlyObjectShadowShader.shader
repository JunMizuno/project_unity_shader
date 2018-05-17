﻿// モデルの影のみを投影するシェーダー
Shader "Custom/OnlyObjectShadowShader"
{

	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
	}

	SubShader
	{
		Tags 
		{ 
			"Queue"="AlphaTest"
			"IgnoreProjector"="True"
			"RenderType"="TransparentCutout"
		}

		LOD 200

		Blend Zero SrcColor
		
		CGPROGRAM
		#pragma surface surf ShadowOnly alphatest:_Cutoff

		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
		};

		// この関数で影のみの計算をすでにしてくれている(各引数から値を取得して次に渡すだけ)
		inline fixed4 LightingShadowOnly(SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
			fixed4 c;

			c.rgb = s.Albedo * atten;
			c.a = s.Albedo;

			return c;
		}

		// サーフェイスシェーダー
		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 c = _Color;

			o.Albedo = c.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
