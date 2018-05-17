// 影とモデル拡大を自前で実装(影は未完成・・・)
// ShadowCamera.csと合わせて使用すること
// このシェーダーをアタッチしたマテリアルのLightDepthには、DirectionalLightにアタッチしたカメラのTargetTexture(Assets→Create→RenderTextureで作成したもの)を設定のこと
Shader "Custom/TestCustomShadowShader"
{
	Properties
	{
		// デフォルト
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("MainTexture (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		// 法線方向に拡大させるベクトル値を設定する
		_OutlineWidth ("OutlineWidth", Range(0.0,5.0)) = 0.0

		// 光源からのDepthRenderTexture
		_LightDepthTex("LightDepth", 2D) = "white" {}

		// 影の濃さ
		_ShadowValue("ShadowValue", Range(0.001,1)) = 1
	}

	SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float _OutlineWidth;
		float4 _Color;
		float4 _MainTex_ST;		// ライブラリ内部で使用しているため宣言のみ必須

		// 光源からのDepthRenderTexture
		sampler2D _LightDepthTex;

		// 光源視点からの射影変換行列
		float4x4 _LightVP;

		// 影の濃さ
		float _ShadowValue;

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
			float4 shadowVertex : TEXCOORD1;
		};

		v2f vert(vertInput v)
		{
			// 法線方向に拡大させるための計算
			v.vertex.xyz += normalize(v.normal) * _OutlineWidth;

			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);

			// 光源視点の変換座標
			//※この辺りの計算がおかしいかもしれない(あるいは_LightVPの値が正しくない？？)
			//※shadowVertexのzがモデルと重なっている模様・・・
			o.shadowVertex = mul(_LightVP, v.vertex);

			o.uv = TRANSFORM_TEX(v.uv, _MainTex);

			return o;
		}

		fixed4 frag(v2f IN) : SV_TARGET
		{
			float shadowRatio = 1;

			// ライトから見たときの深度
			float4 lightDepth = tex2D(_LightDepthTex, IN.shadowVertex.xy);

			// デバッグ
			//return lightDepth.r;
			//return IN.shadowVertex.z;

			// DepthRenderTextureの深度とライト視点のカメラからの距離を比べる
			float diff = IN.shadowVertex.z - lightDepth.r;

			// DepthRenderTextureの深度の方が小さい場合、地面との間に遮蔽物があるとみなしてその箇所を影と判定する
			if(diff >= 0)
			{
				return fixed4(0.0, 0.0, 0.0, 1.0);
			}

			return tex2D(_MainTex, IN.uv.xy);
		}

		ENDCG

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}

	// これを設定すると予め所期のモデルサイズで影を生成してくれるデフォルトシェーダー
	//FallBack "Diffuse"
}