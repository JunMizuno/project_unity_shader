// 円などを波状で動かすシェーダー
Shader "Custom/CircleWaveShader"
{
	Properties
	{
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_SubTex ("SubTex (RGB)", 2D) = "white" {}
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
		#pragma surface surf Standard
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _SubTex;
		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_SubTex;
			float3 worldPos;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// テクスチャの色を取得
			fixed4 mainTexColor = tex2D(_MainTex, IN.uv_MainTex);
			fixed4 subTexColor = tex2D(_SubTex, IN.uv_SubTex);

			float dist = distance(fixed3(0, 0, 0), IN.worldPos);

			// ランダム性を持たせる
			// abs(sin(x))でサイン波のY軸のマイナス分の波形がカットされる形になる(通常のサイン波よりも山の感覚が短くなる)
			float val = abs(sin(dist * 3.0 - _Time * 100));

			// サイン波の山の頂点付近のものの場合(_MainTexで円を描く)
			if(val > 0.98)
			{
				o.Albedo = fixed3(mainTexColor.r, mainTexColor.g, mainTexColor.b);
				o.Alpha = mainTexColor.a;
			}
			// それ以外(_SubTexで塗りつぶす)
			else
			{
				o.Albedo = fixed3(subTexColor.r, subTexColor.g, subTexColor.b);
				o.Alpha = subTexColor.a;
			}
		}

		ENDCG
	}

	FallBack "Diffuse"
}
