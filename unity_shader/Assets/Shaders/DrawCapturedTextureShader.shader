// 外部からテクスチャを受け取ってマテリアルに使用するシェーダー
// CreateRenderTexture.csと合わせて使用すること(シェーダー自体は受け取ったテクスチャをそのまま描画しているだけ)
Shader "Custom/TestMyShader3"
{
	// インスペクター上のプロパティ
	Properties
	{

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

			// レンダリングされたテクスチャ(外部から受け取る)
			sampler2D _CapturedTex;

			struct Input
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			// 頂点シェーダー
			v2f vert(Input v)
			{
				// アウトプット
				v2f o;

				// 座標変換
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				return o;
			}

			// フラグメントシェーダー
			fixed4 frag(v2f IN) : SV_TARGET
			{
				fixed4 c = tex2D(_CapturedTex, IN.uv);

				return c;
			}

			ENDCG
		}
	}
}
