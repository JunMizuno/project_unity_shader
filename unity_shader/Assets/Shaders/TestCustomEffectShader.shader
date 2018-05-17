// テクスチャが変化するシェーダー
Shader "Custom/TestCustomEffectShader"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Pass
		{
			Tags
			{
				"RenderType"="Opaque"
			}

			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;

			struct vertInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(vertInput v)
			{
				v2f o;

				// モデルの描画位置自体をコントロールする
				// 3Dモデルテスト(収縮する)
				//v.vertex.x += v.normal.x * (_CosTime.a * 0.5);
				//v.vertex.y = v.vertex.y + (v.normal.y * (_SinTime.a + 1.0));		// 0.0〜1.0の間で遷移するように調整
				//v.vertex.z += v.normal.z * (_SinTime.a * 0.5);

				// 3Dモデルテスト(ウネウネ動く)
				//v.vertex.x += 0.05 * v.normal.x * sin((v.vertex.y + _Time.x * 3) * 3.14 * 8);
				//v.vertex.y += 0.05 * v.normal.y * sin((v.vertex.y + _Time.x * 3) * 3.14 * 8);
				//v.vertex.z += 0.05 * v.normal.z * sin((v.vertex.y + _Time.x * 3) * 3.14 * 8);

				// 2Dモデルテスト(ただの上下運動)
				// 2Dは法線情報が使えないので注意・・・
				//v.vertex.x += (0.15 * cos((_Time.x * 3) * 3.14 * 8)) * v.vertex.z;
				//v.vertex.z += 0.05 * sin((_Time.x * 3) * 3.14 * 8);

				// 2Dモデルテスト(回転しているように見える)
				//v.vertex.x = v.vertex.x * (_CosTime.a);
				//v.vertex.z = v.vertex.z * (_SinTime.a);

				// 座標変換処理
				o.vertex = UnityObjectToClipPos(v.vertex);

				// ピクセルの参照する位置をコントロールする
				//v.uv.x += (_CosTime.y * 1.0);
				//v.uv.y += (_SinTime.y * 1.0);
				//v.uv.x += _SinTime.a;
				//v.uv.y += _Time.y;

				// UV座標情報
				o.uv = v.uv;

				return o;
			}

			// フラグメントシェーダー
			// 色を返しているだけ
			fixed4 frag(v2f IN) : SV_TARGET
			{
				return tex2D(_MainTex, IN.uv);
			}

			ENDCG
		}
	}
}
