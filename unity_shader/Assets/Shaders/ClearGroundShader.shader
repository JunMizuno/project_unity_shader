// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 影つき透明地面のシェーダー(地面となるマテリアルにアタッチ)
// カメラのClearFlagsがSkyBoxだと機能しない、その場合はカメラをもう1つ追加してSkyBoxを専用で写す必要がある模様
Shader "Custom/ClearGroundShader"
{
	Properties
	{
		_ShadowIntensity ("Shadow Intensity", Range(0,1)) = 0.6
	}

	SubShader
	{
		Pass
		{
			Tags
			{
				"Queue"="geometory-1"	// 1999になるように
				"RenderType"="opaque"
			}

			ColorMask 0
		}

		Pass
		{
			Tags
			{
				"RenderType"="Transparent"
				"Queue"="Transparent"
				"LightMode"="ForwardBase"
			}

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			uniform fixed4 _Color;
			uniform float _ShadowIntensity;

			struct v2f
			{
				float4 pos :SV_POSITION;
				LIGHTING_COORDS(0,1)
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);

				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				float attenuation = LIGHT_ATTENUATION(i);
				return fixed4(0,0,0,(1-attenuation) * _ShadowIntensity);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
