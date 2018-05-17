using UnityEngine;

// 分解シェーダーの使用例スクリプト
public class Dissolve : MonoBehaviour
{
	// 再生時間
	[SerializeField] 
	private float time = 1.0f;

	// 再生までの待ち時間
	[SerializeField]
	private float waitTime = 1.0f;

	// Dissolveシェーダーを組み込んだマテリアル
	private Material material = null;

	private int _Width = 0;
	private int _CutOff = 0;

	// 残時間
	private float duration = 0.0f;

	// 再生時間の半分(調整用の値)
	private float halfTime = 0.0f;

	/// <summary>
	/// 開始時
	/// </summary>
	void Start ()
	{
		material = GetComponentInChildren<Renderer> ().material;
		_Width = Shader.PropertyToID ("_Width");
		_CutOff = Shader.PropertyToID ("_CutOff");

		if (material != null) {
			material.SetFloat (_CutOff, 1.0f);
			material.SetFloat (_Width, 1.0f);
		}

		halfTime = time / 4.0f * 3.0f;		// 3/4の値にしているのは調整のため
		duration = time;
	}

	/// <summary>
	/// 更新
	/// </summary>
	void Update ()
	{
		float delta = Time.deltaTime;

		// 待ち時間
		waitTime -= delta;
		if (waitTime > 0.0f) {
			return;
		}

		duration -= delta;
		if (duration < 0.0f) {
			duration = 0.0f;
		}

		// しきい値のアニメーション(再生時間の上半分時間で1〜0で推移)
		float cutOff = (duration - halfTime) / halfTime;
		if (cutOff < 0.0f) {
			cutOff = 0.0f;
		}

		// 幅のアニメーション(再生時間の下半分時間で1〜0で推移)
		float width = (halfTime - duration) / halfTime;
		if (width < 0.0f) {
			width = 0.0f;
		}
		width = 1.0f - width;

		// シェーダーに値を渡す
		if (material != null) {
			material.SetFloat (_CutOff, cutOff);
			material.SetFloat (_Width, width);
		}
	}
}
