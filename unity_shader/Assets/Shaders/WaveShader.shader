// 波シェーダー(uv移動で表現)
Shader "Custom/WaveShader"
{
	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {}
		_WaveStrength ("WaveStrength", Range(0.01, 2.00)) = 0.01
	}

	SubShader
	{
		Pass
		{
			Tags
			{
				"Queue"="Transparent"		// 背景の色抜きの場合は設定必須
				"RenderType"="Opaque"
			}
					
			CGPROGRAM
			//#pragma surface surf Lambert alpha vertex:vert		// カスタムしたバーテックスシェーダー(vert)を使用するという宣言
			//#pragma target 3.0

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _WaveStrength;

			struct vertInput
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(vertInput v)
			{
				// 波動計算(波動方程式ではない)
				float amp = _WaveStrength * sin(_Time * 100 + v.vertex.x * 100);				// 隣り合う頂点とズレを生じさせるため、sin関数の引数にX座標を足し込んでいる
				v.vertex.xyz = float3(v.vertex.x, v.vertex.y + amp, v.vertex.z);				// Y座標をずらす
				v.vertex.a = 1.0;
				//v.normal = normalize(float3(v.normal.x + _offset, v.normal.y, v.normal.z));

				// UVテクスチャのスクロール計算
				v.uv.x += 0.4 * _Time;
				v.uv.y += 0.8 * _Time;

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				return o;
			}

			fixed4 frag(v2f IN) : SV_TARGET
			{
				fixed4 c = tex2D(_MainTex, IN.uv);

				return c;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
