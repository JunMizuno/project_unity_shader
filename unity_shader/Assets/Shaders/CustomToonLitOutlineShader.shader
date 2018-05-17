// アウトライン
Shader "Custom/CustomToonLitOutlineShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_RampTex ("RampTex (RGB)", 2D) = "gray" {}
		[Enum(OFF, 0, FRONT, 1, BACK, 2)] _CullMode("Cull Mode", int) = 2		// OFF、FRONT、BACKを設定
		_StencilRefMain("StencilRefMain", Range(0,255)) = 128
		_OutlineColor("OutlineColor", Color) = (0,0,0,1)
		_OutlineWidth("OutlineWidth", Range(0.001, 0.03)) = 0.005
	}

	// インクルード設定
	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		UNITY_FOG_COORDS(0)
		fixed4 color : COLOR;
	};

	uniform float _OutlineWidth;
	uniform float4 _OutlineColor;

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
		float2 offset = TransformViewToProjection(normal.xy);

		o.pos.xy += offset * o.pos.z * _OutlineWidth;
		o.color = _OutlineColor;
		UNITY_TRANSFER_FOG(o, o.pos);

		return o;
	}
	ENDCG

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		// 外部シェーダーファイルから処理を抜粋
		UsePass "Custom/CustomLitToonShader/FORWARD"

		Pass
		{
			Name "OUTLINE"

			Tags
			{
				"LightMode"="Always"
			}

			Stencil
			{
				Ref [_StencilRefMain]
				Comp Always
				Pass Replace
			}

			Cull Front
			ZWrite On
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			fixed4 frag(v2f IN) : SV_TARGET
			{
				UNITY_APPLY_FOG(IN.fogCoord, IN.color);
				return IN.color;
			}

			ENDCG
		}
	}

	Fallback "Custom/CustomToonLitShader"
}
