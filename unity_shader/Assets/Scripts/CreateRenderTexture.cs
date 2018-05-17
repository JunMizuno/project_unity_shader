using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// サブカメラをセットしてそのレンダーテクスチャをキャンバスへレンダリングする
/// @memo. サブカメラにセットしたほうが適切かもしれない
/// @memo. いちいちレンダリングし直しているため、処理が重くなる可能性大。カメラを別ウインドウで表示させたほうが早いかもしれない。
/// @memo. レンダーテクスチャを直接キャンバスにセットすると色合いがおかしくなったため、テクスチャに落とし込みをかけています
/// </summary>
public class CreateRenderTexture : MonoBehaviour
{
	// カメラの画面をレンダリングするレンダーテクスチャ(動的生成)
	private RenderTexture renderTexture = null;

	// レンダリングした画面をテクスチャに変換するときの格納用テクスチャ(動的生成)
	private Texture2D screenShot = null;

	// 画面表示用Canvas内のRawImageを格納する変数(インスペクター上から設定)
	public GameObject Obj = null;

	// サブカメラを格納する変数(インスペクター上から設定)
	public Camera subCamera = null;

	// マテリアルを設定
	public Material material;

	// シェーダーに値を渡すときのネームID
	private int textureID = 0;

	// サブウインドウとするキャンバスのサイズ調整用の拡縮率
	private const float CANVAS_SCALE = 3.0f;

	/// <summary>
	/// 起動時(動的生成)
	/// </summary>
	void Awake ()
	{
		// レンダーテクスチャを生成
		renderTexture = new RenderTexture (Screen.width, Screen.height, 24);
		renderTexture.enableRandomWrite = false;

		// テクスチャを生成
		screenShot = new Texture2D (Screen.width, Screen.height, TextureFormat.RGB24, false);

		// サブカメラのTagetTextureに動的に生成したRenderTextureをセット
		if (subCamera && renderTexture) {
			subCamera.targetTexture = renderTexture;
		}
	}

	/// <summary>
	/// 開始時
	/// </summary>
	void Start ()
	{
		// キャンバスウインドウのサイズと座標をセット(座標は適宜変更のこと)
		if (Obj) {
			// アスペクト比を算出
			int screenWidthAspect = (int)(Screen.width * Screen.height) / (int)Screen.height;
			int screenHeightAspect = (int)(Screen.width * Screen.height) / (int)Screen.width;

			Obj.GetComponent<RectTransform> ().sizeDelta = new Vector2 (Screen.width * Screen.height / screenHeightAspect / CANVAS_SCALE, Screen.width * Screen.height / screenWidthAspect / CANVAS_SCALE);
			Obj.GetComponent<RectTransform> ().position += new Vector3 (Screen.width * Screen.height / screenHeightAspect / CANVAS_SCALE, Screen.width * Screen.height / screenWidthAspect / CANVAS_SCALE, 0.0f);
		}

		// シェーダーに値を渡すときのIDを受け取り、登録する
		if (material) {
			textureID = Shader.PropertyToID ("_CapturedTex");
		}
	}

	/// <summary>
	/// 更新
	/// </summary>
	void Update ()
	{
		// @memo. アップデートで処理しないと画像は更新されない模様・・・
		if (Obj) {
			if (screenShot) {
				// キャンバスにテクスチャをセット
				Obj.GetComponent<CanvasRenderer> ().SetTexture (screenShot);

				// マテリアルにアタッチしているシェーダーにテクスチャを渡す
				if (material) {
					material.SetTexture (textureID, screenShot);
				}
			}
		}
	}

	// 破棄
	void OnDestroy ()
	{
		// レンダーテクスチャを破棄
		if (renderTexture) {
			Destroy (renderTexture);
		}

		renderTexture = null;

		// スクリーンショットを破棄
		if (screenShot) {
			Destroy (screenShot);
		}

		screenShot = null;
	}

	// レンダリング時(直前？)にコールされる関数
	void OnPostRender ()
	{
		// 画面のスクリーンショットを生成
		if (screenShot) {
			screenShot.ReadPixels (new Rect (0, 0, Screen.width, Screen.height), 0, 0);
			screenShot.Apply ();
		}
	}
}
