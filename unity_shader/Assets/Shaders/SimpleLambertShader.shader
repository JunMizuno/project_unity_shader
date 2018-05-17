// ランバート拡散照明のシェーダー
Shader "Custom/SimpleLambertShader"
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
			"Queue"="Geometry"
			"RenderType"="Opaque"
		}

		LOD 200
		
		CGPROGRAM
		#pragma surface surf SimpleLambert		// LightingXX(XXの部分にSimpleLambertと名称をつけて関数として宣言・定義する)
		#pragma target 3.0

		sampler2D _MainTex;
		fixed4 _Color;

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

		// attenはライトの減衰率(attenuation)
		half4 LightingSimpleLambert(SurfaceOutput s, half3 lightDir, half atten)
		{
			half NdotL = max(0, dot(s.Normal, lightDir));
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * NdotL + fixed4(0.2, 0.2, 0.2, 1.0);
			c.a = s.Alpha;

			return c;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
