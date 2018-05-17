// トゥーンシェーダー
Shader "Custom/CustomToonLitShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_RampTex ("RampTex (RGB)", 2D) = "white" {}
		[Enum(OFF, 0, FRONT, 1, BACK, 2)] _CullMode("Cull Mode", int) = 2		// OFF、FRONT、BACKを設定
		_StencilRefMain ("Stencil Ref Main", Range(0, 255)) = 128
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		LOD 200

		Cull [_CullMode]

		Stencil
		{
			Ref [_StencilRefMain]
			Comp Always
			Pass Replace
		}

		CGPROGRAM
		#pragma surface surf ToonRamp
		#pragma lighting ToonRamp exclude_path:prepass

		sampler2D _MainTex;
		sampler2D _RampTex;
		fixed4 _Color;

		inline half4 LightingToonRamp(SurfaceOutput s, half3 lightDir, half atten)
		{
			#ifndef USING_DIRECTIONAL_LIGHT
			lightDir = normalize(lightDir);
			#endif

			half d = dot(s.Normal, lightDir) * 0.5 + 0.5;
			half3 ramp = tex2D(_RampTex, float2(d, d)).rgb;

			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
			c.a = 0;

			return c;
		}

		struct Input
		{
			float2 uv_MainTex : TEXCOORD0;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
