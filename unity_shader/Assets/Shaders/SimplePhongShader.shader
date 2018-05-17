// フォン反射シェーダー(ピンポイントで反射光を当てる)
Shader "Custom/SimplePhongShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_HightLightPoint ("HighLightPoint", Range(0.0, 40.0)) = 10.0
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		LOD 200
		
		CGPROGRAM
		#pragma surface surf SimplePhong		// LightingXX(XXの部分にSimplePhongと名称をつけて関数として宣言・定義する)
		#pragma target 3.0

		sampler2D _MainTex;
		fixed4 _Color;
		float _HightLightPoint;

		struct Input
		{
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		half4 LightingSimplePhong(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half NdotL = max(0, dot(s.Normal, lightDir));
			float3 R = normalize(-lightDir + 2.0 * s.Normal * NdotL);
			float3 spec = pow(max(0, dot(R, viewDir)), _HightLightPoint);

			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * NdotL + spec + fixed4(0.1, 0.1, 0.1, 1.0);
			c.a = s.Alpha;

			return c;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
