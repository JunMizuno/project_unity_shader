// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// バンプマップシェーダー(光の影響強め)
Shader "Custom/BumpMapShader"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}			// メインテクスチャ
		_NormalTex ("Normal (RGB)", 2D) = "while" {}		// 法線マップ(バンプマップ)
		_DiffuseColor ("Diffuse Color", Color) = (0,0,0,0)
		_DiffuseValue ("DiffuseValue", Range(0.0, 10.0)) = 1.0
	}

	SubShader
	{
		Tags
		{ 
			"RenderType"="Opaque"
			"LightMode"="ForwardBase"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			//#include "AutoLight.cginc"		// ライティング実装のためにインクルード必須

			// Input
			struct vertInput
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				float4 tangent : TANGENT0;
			};

			// Vertex To Fragment
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _NormalTex;

			float4 light_pos;
			//uniform float k_diffuse;
			uniform float k_ambient;

			float4 _DiffuseColor;
			float4 _SpecularColor;
			float _DiffuseValue;

			// 接空間への変換用ベクトルを作成
			// t:tangent b:binormal n:normal
			float4x4 InvTangentMatrix(float3 t, float3 b, float3 n)
			{
				float4x4 mat = float4x4(float4(t.x, t.y, t.z, 0), float4(b.x, b.y, b.z, 0), float4(n.x, n.y, n.z, 0), float4(0, 0, 0, 1));

				return transpose(mat);
			}

			// 頂点シェーダー
			v2f vert(vertInput v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);		// 座標変換
				o.uv = v.texcoord;								// UV座標

				float4 ms_normal = normalize(mul(v.normal, unity_WorldToObject));

				float3 n = normalize(ms_normal);
				float3 t = v.tangent;
				float3 b = cross(n, t);

				o.lightDir = mul(light_pos, InvTangentMatrix(t, b, n));

				return o;
			}

			// フラグメントシェーダー
			float4 frag(v2f i) : SV_TARGET
			{
				float4 mainColor = tex2D(_MainTex, i.uv);

				//float3 normal = normalize(tex2D(_NormalTex, i.uv).xyz * 2.0 + 1.0);
				float3 normal = float4(UnpackNormal(tex2D(_NormalTex, i.uv)), 1);
				float3 light = normalize(i.lightDir.xyz);
				float diffuse = max(0, dot(normal, light)) * _DiffuseValue;

				float4 lastedColor = diffuse * _DiffuseColor + k_ambient;

				// メインカラーを反映させない場合はこちら
				//return lastedColor;

				return mainColor + lastedColor;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
