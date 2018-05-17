// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 基本となる頂点・フラグメントシェーダー
Shader "Custom/BasicV2FShader"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass
		{
			Tags
			{
				"Queue"="Transparent"
				"RenderType"="Transparent"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _Color;

			struct vertInput
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			v2f vert(vertInput v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = v.normal;

				return o;
			}

			fixed4 frag(v2f IN) : SV_TARGET
			{
				fixed4 mainColor = tex2D(_MainTex, IN.uv);

				return mainColor * _Color;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
