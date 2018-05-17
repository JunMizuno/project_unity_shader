// 2Dアウトライン
Shader "Custom/2DTextureOutlineShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[MaterialToggle] PixelSnap ("Pixel snap", float) = 0
		_OutLineSpread ("OutLine Spred", Range(0.00, 0.05)) = 0.01
		_OutLineColor ("OutLine Color", color) = (0,0,0,1)
		_ShadowOffsetX ("Shadow OffsetX", float) = 0.02
		_ShadowOffsetY ("Shadow OffsetY", float) = -0.02
		_ShadowColor ("Shadow Color", color) = (0,0,0,0.8)
		_Alpha ("Alpha", Range(0.0, 1.0)) = 1
		_TextureScale ("Texture Scale", Range(0.0, 2.0)) = 1.0
	}

	SubShader
	{
		// タグの設定
		Tags
		{
			"Queue"="Transparent"			// レンダーの描画順を表すキュー
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DUMMY PIXELSNAP_ON

			#include "UnityCG.cginc"

			// 入力情報
			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			// 出力情報
			struct v2f
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			half _OutLineSpread;
			fixed4 _OutLineColor;
			half _ShadowOffsetX;
			half _ShadowOffsetY;
			fixed4 _ShadowColor;
			half _Alpha;
			float _TextureScale;

			// 頂点シェーダー
			v2f vert(appdata v)
			{
				// アウトライン専用のスケール
				fixed scale = _TextureScale;

				// 拡大させた後に、拡大分の半分を左にずらして中心に位置を取る
				float2 tex = v.texcoord * scale;
				tex -= (scale - 1) / 2;

				// 出力情報
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = tex;
				o.color = v.color;

				#ifdef PIXELSNAP_ON
				o.vertex = UnityPixelSnap(o.vertex);
				#endif

				return o;
			}

			// 読み込んでいるライブラリ内で使用しているので宣言しているとのこと
			sampler2D _AlphaTex;
			float _AlphaSplitEnabled;

			// ピクセル情報を取得
			fixed4 SampleSpriteTexture(float2 uv)
			{
			    // テクスチャとそのUV座標を取得して、テクスチャ上のピクセルの色を計算して返す
				fixed4 retColor = tex2D(_MainTex, uv);

				#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
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
				const fixed THRESHOLD = 0.1;

				// 元のテクスチャ色
				fixed4 base = SampleSpriteTexture(IN.texcoord) * IN.color;

				// アウトライン色
				fixed4 out_color = _OutLineColor;
				_OutLineColor.a = 1;
				half2 line_w = half2(_OutLineSpread, 0);		// アウトラインの幅を設定
				fixed4 line_color = SampleSpriteTexture(IN.texcoord + line_w.xy)
								  	+ SampleSpriteTexture(IN.texcoord - line_w.xy)
								  	+ SampleSpriteTexture(IN.texcoord + line_w.yx)
								  	+ SampleSpriteTexture(IN.texcoord - line_w.yx);
				_OutLineColor *= (line_color.a);
				_OutLineColor.rgb = out_color.rgb;
				_OutLineColor = lerp(base, _OutLineColor, max(0, sign(_OutLineSpread)));

				// 影
				fixed4 shadow = SampleSpriteTexture(IN.texcoord - half2(_ShadowOffsetX, _ShadowOffsetY));
				shadow = _ShadowColor * max(0, sign(shadow.a - THRESHOLD));
				shadow.a *= _ShadowColor.a;
				_ShadowColor = shadow;

				// 合成
				fixed4 main_color = base;
				main_color = lerp(main_color, _OutLineColor, (1 - main_color.a));
				main_color.a = _Alpha * max(0, sign(main_color.a - THRESHOLD));

				_ShadowColor.a = min(_Alpha, shadow.a);
				main_color = lerp(_ShadowColor, main_color, max(0, sign(main_color.a - THRESHOLD)));
				return main_color;
			}
			ENDCG
		}
	}
}
