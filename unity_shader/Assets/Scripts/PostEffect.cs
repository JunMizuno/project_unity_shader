using System.Collections;
using UnityEngine;

// 設定させたマテリアルを用いてポストエフェクトを掛ける
// このスクリプト自体をメインカメラにアタッチすること
// マテリアルをセットした上でタイプ設定をしなかった場合は挙動がおかしくなるので注意のこと
public class PostEffect : MonoBehaviour
{
	// 各種マテリアルをセット
	public Material effectMaterial;

	public enum EffectType
	{
		None,
		WipeCircle,
		Sepia,
		GrayScale,
		RasterScroll,
		Blur,
	}

	[Header ("EffectType Settings")]
	public EffectType effectType;

	// @memo. WipeCircleShaderをアタッチしたマテリアル、タイプはWipeCircleを指定(シーンに使用することを想定してステータスはスクリプト側で設定)
	// @memo. SepiaToneShaderをアタッチしたマテリアル、タイプはSepiaを指定(仕様上ステータスはマテリアル側で設定)
	// @memo. GrayScaleShaderをアタッチしたマテリアル、タイプはGrayScaleを指定(仕様上ステータスはマテリアル側で設定)
	// @memo. RasterScrollShaderをアタッチしたマテリアル、タイプはRasterScrollを指定(仕様上ステータスはマテリアル側で設定)
	// @memo. BlurShaderをアタッチしたマテリアル、タイプはBlurを指定(シーンに使用することを想定してステータスはスクリプト側で設定)

	[Header ("WipeCircle Settings")]
	// 基準値は2.0f(この値を大きくすれば実質エフェクト開始までのウェイトがかかる)
	public float radiusValue = 2.0f;

	// ウェイトをかけるときのサークルの半径の値(0.0fにすればウェイト処理はかからない)
	public float wipePauseRadiusValue = 0.3f;

	// ウェイト時間を秒単位で指定
	public float wipeFadeWaitTime = 2.0f;

	// ウェイト処理が入るまでのフェードアウトのスピード値
	public float wipeFadeStartSpeed = 2.0f;

	// ウェイト処理後に加算されるスピード値
	public float wipeFadeAddSpeed = 0.0f;

	// ウェイト処理をしたかどうか
	private bool wipeCircleWaitState = false;

	[Header ("Blur Settings")]
	// 左右に揺れる値を設定(素早く揺らすのであれば下記設定程度が適切と思われる)
	public float blurDiffValue = 0.0f;
	private const float BLUR_SPEED = 64.0f;
	private const float BLUR_CONTROL_VALUE = 0.002f;

	// シェーダーに値を渡す時のID
	private int blueDiffValueID = 0;

	/// <summary>
	/// 開始時
	/// </summary>
	void Start ()
	{
		if (effectMaterial) {
			switch (effectType) {
			case EffectType.WipeCircle:
				StartCoroutine (CalcRadius ());
				break;
			case EffectType.Sepia:
				break;
			case EffectType.GrayScale:
				break;
			case EffectType.RasterScroll:
				break;
			case EffectType.Blur:
				blueDiffValueID = Shader.PropertyToID ("_Diff");
				break;
			default:
				break;
			}
		}
	}

	// 全てのオブジェクトがレンダリングされた後に呼び出される関数
	void OnRenderImage (RenderTexture src, RenderTexture dest)
	{
		// src画像にmonoToneに設定されたポストエフェクトをかけてdest画像に描き込む
		if (effectMaterial) {
			switch (effectType) {
			case EffectType.WipeCircle:
				// アスペクト比を算出
				int screenWidthAspect = (int)(Screen.width * Screen.height) / (int)Screen.height;
				int screenHeightAspect = (int)(Screen.width * Screen.height) / (int)Screen.width;

				// シェーダーへ渡す値のIDはint型で宣言
				int _WidthAspect = Shader.PropertyToID ("_WidthAspect");
				int _HeightAspect = Shader.PropertyToID ("_HeightAspect");
				int _Radius = Shader.PropertyToID ("_Radius");

				// シェーダーへ各値を渡す
				effectMaterial.SetFloat (_WidthAspect, screenWidthAspect);
				effectMaterial.SetFloat (_HeightAspect, screenHeightAspect);
				effectMaterial.SetFloat (_Radius, radiusValue);

				break;
			case EffectType.Sepia:
				break;
			case EffectType.GrayScale:
				break;
			case EffectType.RasterScroll:
				break;
			case EffectType.Blur:
				// 揺れのパターンをサイン波で計算
				blurDiffValue = Mathf.Sin (Time.time * BLUR_SPEED) * BLUR_CONTROL_VALUE;

				// シェーダーへ値を渡す
				effectMaterial.SetFloat (blueDiffValueID, blurDiffValue);

				break;
			default:
				break;
			}

			// マテリアルの効果を書き込み
			Graphics.Blit (src, dest, effectMaterial);
		}
	}

	/// <summary>
	/// 半径の減算
	/// </summary>
	/// <returns>The radius.</returns>
	private IEnumerator CalcRadius ()
	{
		while (true) {
			if (radiusValue < 0.0f) {
				yield break;
			}

			// 規定値に達したときの1回限りの処理
			if (radiusValue <= wipePauseRadiusValue && !wipeCircleWaitState) {
				wipeCircleWaitState = true;
				wipeFadeStartSpeed += wipeFadeAddSpeed;
				// @memo. 将来的には別コルーチンでウェイトをかけても良いかもしれない
				yield return new WaitForSeconds (wipeFadeWaitTime);
			}

			radiusValue -= Time.deltaTime * wipeFadeStartSpeed;
			yield return null;
		}
	}
}
