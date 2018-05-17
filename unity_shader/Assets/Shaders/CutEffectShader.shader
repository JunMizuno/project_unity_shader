// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// カット(スリット)シーンのシェーダー
// テクスチャを歪ませながらブラックアウトさせています
Shader "Custom/CutEffectShader"
{
	// インスペクター上のプロパティ
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Size ("Size", float) = 1
		_AnimeTime ("Animation Time", Range(0,1)) = 1
	}

	SubShader
	{
		ZTest Always
		Cull Off
		//ZWrite Off

		Fog { Mode Off }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.texcoord.xy);
				return o;
			}

			sampler2D _MainTex;
			float _Size;
			float _AnimeTime;

			fixed4 frag(v2f i) : SV_Target
			{
				// _ScreenParamsは定義済みの値
				// _Size変数の中身を変化させるため、_Timeの値を使って変化させています
				// ここではX軸しか変化させないため、.xの値のみ使用しています
				float delta = (_Size * _Time.x) / _ScreenParams.x;
				float visible = 1.0 - floor(frac(i.uv.x / delta) + (_AnimeTime * _Time.y));		// floor(x) x以下の最大の整数を返す、frac(x) xの小数部分を返す

				return fixed4(tex2D(_MainTex, i.uv).rgb * visible, 1.0);
			}

			ENDCG
		}
	}
}
