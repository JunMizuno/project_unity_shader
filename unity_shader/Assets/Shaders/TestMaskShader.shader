// 2Dベタ塗りマスク
// プロパティ実装などのテストケース用
Shader "Custom/TestMaskShader"
{
	Properties
	{
		_MaskColor ("Mask Color", Color) = (0,0,0,0)
		[MaterialToggle] _MaskOn ("Mask On", float) = 0
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", float) = 0
	}

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
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend One OneMinusSrcAlpha		// アルファチャンネルのブレンド設定

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DUMMY PIXELSNAP_ON
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
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
			};

			fixed4 _Color;

			// 頂点シェーダー
			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap(OUT.vertex);
				#endif

				return OUT;
			}

			sampler2D _MainTex;
			fixed4 _MaskColor;
			fixed _MaskOn;

			sampler2D _AlphaTex;
			float _AlphaSplitEnabled;

			// サンプル？？(他サイトから採ってきただけか？？)
			// この関数自体はそのままテクスチャの色情報を取得して変換しているだけ
			fixed4 SampleSpriteTexture(float2 uv)
			{
				fixed4 retColor = tex2D(_MainTex, uv); 

				#if UNITY_TEXTURE_ALPHASPLIT_ARROWED
				if(_AlphaSplitEnabled)
				{
					retColor.a = tex2D(_AlphaTex, uv).r;
				}
				#endif

				return retColor;
			} 

			// フラグメントシェーダー
			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;
				fixed4 m = lerp(c, _MaskColor, _MaskOn);	// マスクをかけた色とメインテクスチャの色を足し込んでいる
				m.rgb *= c.a;
				m.a = c.a;
				return m;
			}

			ENDCG
		}
	}
}
