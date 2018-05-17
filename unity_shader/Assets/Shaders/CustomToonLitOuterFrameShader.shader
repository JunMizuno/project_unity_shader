// トゥーン＋ステンシルテスト＋白枠＋影描画
Shader "Custom/CustomToonLitOuterFrameShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("MainTex (RGB)", 2D) = "white" {}
		_RampTex ("RampTex (RGB)", 2D) = "gray" {}
		[Enum(OFF, 0, FRONT, 1, BACK, 2)] _CullMode("Cull Mode", int) = 2		// OFF、FRONT、BACKを設定
		_StencilRefMain("StencilRefMain", Range(0, 255)) = 128
		_StencilRefOuterFrame("StencilRefOuterShadow", Range(0, 255)) = 112
		_StencilRefShadow("StencilRefShadow", Range(0, 255)) = 96
		_OuterFrameColor("OuterFrameColor", Color) = (1,1,1,1)
		_OuterFrameWidth("OuterFrameWidth", Range(0.0, 1.0)) = 0.02
		_OuterShadowColor("OuterShadowColor", Color) = (0.5,0.5,0.5,0.5)
		_OuterShadowOffset("OuterShadowOffset", Vector) = (-0.5,-0.5,0.0,0.0)
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}

		UsePass "Custom/CustomToonLitShader/FORWARD"

		// Stencil Outer Frame
		Pass
		{
			Name "OUTER FRAME"

			// ステンシル関係の設定
			Stencil
			{
				Ref [_StencilRefOuterFrame]		// 整数値
				Comp Greater					// 比較関数
				Pass Replace					// 合格
			}

			Cull Front
			Zwrite On
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _OuterFrameWidth;
			fixed4 _OuterFrameColor;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				float2 offset = TransformViewToProjection(normal.xy);

				o.pos.xy += offset * o.pos.z * _OuterFrameWidth;
				UNITY_TRANSFER_FOG(o, o.pos);

				return o;
			}

			half4 frag(v2f IN) : COLOR
			{
				return _OuterFrameColor;
			}

			ENDCG
		}

		// Stencil Shadow
		Pass
		{
			Name "OUTER SHADOW"

			Stencil
			{
				Ref [_StencilRefShadow]
				Comp Greater
				Pass Replace
			}

			Cull Off
			ZWrite Off

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _OuterFrameWidth;
			float4 _OuterShadowColor;
			float _StencilScale;
			float2 _OuterShadowOffset;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				float2 offset = TransformViewToProjection(normal.xy);

				o.pos.xy += offset * o.pos.z * _OuterFrameWidth;
				o.pos.x += _OuterShadowOffset.x;
				o.pos.y += _OuterShadowOffset.y;
				UNITY_TRANSFER_FOG(o, o.pos);

				return o;
			}

			half4 frag(v2f IN) : COLOR
			{
				return _OuterShadowColor;
			}

			ENDCG
		}
	}

	FallBack "Custom/CustomToonLitShader"
}
