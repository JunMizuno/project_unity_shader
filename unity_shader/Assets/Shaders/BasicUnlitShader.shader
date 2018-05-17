// ライティング反映なしのテクスチャのみのシンプルシェーダー
Shader "Custom/BasicUnlitShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader
	{
		// @memo. ブレンドを有効にするためにはこれらの設定も必要な模様
		Tags
		{
			"RenderType"="Transparent"
			"Queue"="Transparent"
		}

		LOD 100

		// カリング設定
		Cull Off

		// ブレンド設定
		Blend SrcAlpha OneMinusSrcAlpha		// デプスバッファに書き込まれている色 * SrcAlpha + 今から書き込もうとしている色 * OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
