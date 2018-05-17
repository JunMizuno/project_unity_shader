// 液体表現のシェーダー(面や球体に対して)
// テクスチャに対して使用するためには改良する必要あり
Shader "Custom/LiquidShader"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Threshold ("Threshold", Range(0, 1)) = 0.2
	}

	SubShader
	{
		Pass
		{
			Tags
			{
				"RenderType"="Opaque"
			}
					
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _Color;
			float _Threshold;

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
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f IN) : SV_TARGET
			{
				// テクスチャのカラーを取得
				fixed4 texColor = tex2D(_MainTex, IN.uv);

				// 液体動作の計算
				half2 p = IN.uv.xy;
				half2 a = p * 4.0;
				a.y -= _Time.w * 0.5;
				half2 f = frac(a);
				a -= f;
				f = f * f * (3.0 - 2.0 * f);
				half4 r = frac(sin((a.x + a.y * 1e3) + half4(0, 1, 1e3, 1001)) * 1e5) * 30.0 / p.y;
				half4 ret = half4(p.y + half3(texColor.r, texColor.g, texColor.b) * clamp(lerp(lerp(r.x, r.y, f.x), lerp(r.z, r.w, f.x), f.y) - 30.0, - 0.2, 1.0), 1.0);
				ret *= _Color;

				// グレースケール化して不要な部分を非表示にする
				float check = ret.x * 0.3 + ret.y * 0.6 + ret.z * 0.1;
				if(check < _Threshold)
				{
					// 処理を破棄
					discard;
				}

				return ret;
			}

			ENDCG
		}
	}

	//FallBack "Diffuse"
}
