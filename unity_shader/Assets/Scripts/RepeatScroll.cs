using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// リピートスクロール
/// リピートスクロールシェーダーをアタッチしたマテリアルを使用しているオブジェクトにアタッチすること
/// </summary>
public class RepeatScroll : MonoBehaviour
{

	// リピートスクロールシェーダーをアタッチしたマテリアルを設定
	[SerializeField]
	private Material material;

	// スクロールの基準となるオブジェクトの座標情報
	[SerializeField]
	private Transform target;

	// どちら側にスクロールするかの設定(必ずどちらかがtrue、falseであるように設定のこと)
	[SerializeField]
	private bool XRepeat = true;

	[SerializeField]
	private bool YRepeat = false;

	// スクロールするスピード
	[SerializeField]
	private float repeatSpeed = 0.01f;

	/// <summary>
	/// 更新
	/// </summary>
	void Update ()
	{
		if (target == null) {
			return;
		}

		if (material) {
			if (XRepeat) {
				material.SetFloat ("_OffsetX", target.position.x * repeatSpeed);
			}

			if (YRepeat) {
				material.SetFloat ("_OffsetY", target.position.y * repeatSpeed);
			}
		}
	}
}
