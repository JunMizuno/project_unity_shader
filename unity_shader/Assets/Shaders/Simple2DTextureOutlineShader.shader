// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// シンプルな2Dテクスチャのアウトラインシェーダー
// 使用するテクスチャによって精度が低くなる・・・
Shader "Custom/Simple2DTextureOutlineShader"
{
	// インスペクター上のプロパティ
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_Outline ("Outline", float) = 1
		_OutlineColor ("Outline Color", Color) = (1,0,0,1)
	}

	// 2Dアウトライン(副産物でTinitカラー設定でベタ塗り)
	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		ZWrite Off
		Lighting Off
		Blend One OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile PIXELSNAP_ON
			#pragma shader_feature ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc" 

			struct appdata_t
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 texcoord : TEXCOORD0; 
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			fixed4 _Color;
			float _Outline;
			fixed4 _OutlineColor;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color * _Color;
				#ifdef PIXELSNAP_ON
				o.vertex = UnityPixelSnap(o.vertex);
				#endif

				return o;
			}

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			float4 _MainTex_TexelSize;

			fixed4 SampleSpriteTexture(float2 uv)
			{
				fixed4 retColor = tex2D(_MainTex, uv);

				#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				retColor.a = tex2D(_AlphaTex, uv).r;
				#endif

				return retColor;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;

				if(_Outline > 0 && c.a != 0)
				{
					fixed4 pixelUp = tex2D(_MainTex, IN.texcoord + fixed2(0, _MainTex_TexelSize.y));
					fixed4 pixelDown = tex2D(_MainTex, IN.texcoord - fixed2(0, _MainTex_TexelSize.y));
					fixed4 pixelRight = tex2D(_MainTex, IN.texcoord + fixed2(_MainTex_TexelSize.x, 0));
					fixed4 pixelLeft = tex2D(_MainTex, IN.texcoord - fixed2(_MainTex_TexelSize.x, 0));

					if(pixelUp.a * pixelDown.a * pixelRight.a * pixelLeft.a == 0)
					{
						c.rgba = fixed4(1,1,1,1) * _OutlineColor;
					}
				}

				c.rgb *= c.a;

				return c;
			}

			ENDCG
		}
	}

	// エラー時のデフォルト処理を設定
	FallBack Off
}