// 消滅シェーダー(バンプマップも有効？)
// Dissolve.csと組み合わせて使用
Shader "Custom/DissolveShader"
{
	Properties
	{
		_MainColor ("MainColor", Color) = (1,1,1,1)		// モデルの色
		_MainTex ("BaseTex", 2D) = "white" {}			// モデルのテクスチャー
		_Mask ("Mask To Dissolve", 2D) = "white" {}		// 分解用マスク
		_CutOff ("CutOff Range", Range(0,1)) = 0		// 分解のしきい値
		_Width ("Width", Range(0,1)) = 0.001			// しきい値の幅
		_ColorIntensity ("Intensity", Float) = 1		// 燃え尽きる部分の明るさの強度(BloomとHDRを使わない場合は不要)
		_Color ("Line Color", Color) = (1,1,1,1)		// 燃え尽きる部分の色
		_BumpMap ("NormalMap", 2D) = "bump" {}			// モデルのバンプマップ
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Opaque"
		}

		LOD 300

		Pass
		{
			ZWrite On
			ColorMask 0
		}

		CGPROGRAM
		#pragma surface surf Lambert alpha
		#pragma target 2.0

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _Mask;
		fixed4 _Color;
		fixed4 _MainColor;
		fixed _CutOff;
		fixed _Width;
		fixed _ColorIntensity;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};

		float random(fixed2 p)
		{
			return frac(sin(dot(p, fixed2(12.9898, 78.233))) * 43758.5453);
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			// テクスチャの色を取得
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex) * _MainColor;

			// バンプマッピング
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

			// マスク用テクスチャから濃度を取得(モノクロなのでRチャンネルの値だけ使用する)
			fixed a = tex2D(_Mask, IN.uv_MainTex).r;

			// 燃える切れ端表現(aの値を、「しきい値〜しきい値」+ 幅の範囲を0〜1 として丸める)
			fixed b = smoothstep(_CutOff, _CutOff + _Width, a);
			float rnd = random(IN.uv_MainTex);		// カラーにランダム値を掛け合わせてそれっぽく見せようとした結果です
			o.Emission = (_Color * rnd) * b * _ColorIntensity;

			// 消失する範囲を求める(消失していると判定された箇所のアルファ値をゼロにする)
			fixed b2 = step(a, _CutOff + _Width * 2.0);		// (_CutOff + _Width * 2.0 >= a) ? 1 : 0 と同義
			o.Alpha = b2;
		}

		ENDCG
	}

	//FallBack "Diffuse"
}
