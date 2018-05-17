// 積もらせるシェーダー(表面に色を加算させる)
Shader "Custom/AccrueShader"
{
	Properties
	{
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_AccrueValue ("AccrueValue", Range(0,2)) = 0.0		// 積もらせる物体の質量 
	}

	SubShader
	{
		Tags
		{

		}

		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		fixed4 _Color;
		half _Glossiness;
		half _Metallic;
		half _AccrueValue;

		struct Input
		{
			float2 uv_MainTex;
			float3 worldNormal;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// 上方向の法線情報を取得する(内積)
			float d = dot(IN.worldNormal, fixed3(0.0, 1.0, 0.0));

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			// ここで指定したカラーを法線情報にしたがって上に重ねる
			fixed4 accrueColor = fixed4(0.5, 0.0, 0.0, 1.0);
			c = lerp(c, accrueColor, d * _AccrueValue);

			// デフォルト設定
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1.0;
		}

		ENDCG
	}

	FallBack "Diffuse"
}
