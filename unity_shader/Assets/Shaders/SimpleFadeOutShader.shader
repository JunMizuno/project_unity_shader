// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 
Shader "Custom/SimpleFadeOutShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	// フェードアウト
	SubShader
	{
		ZTest Always
		Cull Off
		//ZWrite Off	// ZWriteをオフにすると描画されない？？

		Fog { Mode Off }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert			// 頂点シェーダー
			#pragma fragment frag		// フラグメントシェーダー

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

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				// fixed4のx,y,zそれぞれの要素にy/2を適応させるため、_Time.yyy/2としています 
				fixed4 black = 1 - fixed4(_Time.yyy / 2, 1);
				col *= black;
				return col;
			}

			ENDCG
		}
	}
}