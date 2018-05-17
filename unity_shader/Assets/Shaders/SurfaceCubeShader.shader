// Skyboxの原理を利用して、球体の表現を行うシェーダー
Shader "Custom/SurfaceCubeShader"
{
	Properties
	{
		_EnvMap ("EnvMap", Cube) = "white" {}		// キューブマップ化したテクスチャを設定
		_Color ("Color", Color) = (1,1,1,1)
		_Alpha ("Alpha", Range(0.0, 1.0)) = 1.0
		_RefractValue ("RefractValue", Range(0.001, 1.000)) = 0.667
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"RenderType"="Opaque"
		}

		CGPROGRAM
		#pragma surface surf Lambert alpha

		samplerCUBE _EnvMap;

		struct Input
		{
			float3 worldRefl;
			float3 viewDir;
			float3 worldNormal;
		};

		float4 _Color;
		float _Alpha;
		float _RefractValue;

		void surf (Input IN, inout SurfaceOutput o)
		{
			// 縁辺部分(視線ベクトルと法線ベクトルの角度が90度に近い面)の反射光の色の足し込み率を計算
			// 面が視点に対して正面を向いているほど1.0に近く(反射光量が大きく)なり、視点より外れているほど0.0に近くなる
			float margin = 1.0 - dot(normalize(IN.viewDir), normalize(IN.worldNormal));

			float3 refractVec = refract(normalize(IN.viewDir), normalize(IN.worldNormal), _RefractValue);
			// Emissionは自発光、Albedo(表面ベースカラー)の代わりに使用
			// 縁辺に近いほど反射光が少なくなると想定して屈折光が見えやすくなるように調整
			o.Emission = texCUBE (_EnvMap, refractVec).rgb * (1.0 - margin);
			o.Emission += texCUBE(_EnvMap, IN.worldRefl).rgb * margin * _Color.xyz;
			o.Alpha = _Alpha;
		}
		ENDCG
	}

	//FallBack "Diffuse"
}
