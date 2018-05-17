using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 透過処理を行うかどうかのしきい値を計算する
/// </summary>
public class CalcAlpha : MonoBehaviour
{

	public Material material = null;

	// シェーダーに値を渡すときに使用するID
	private int DiscardValueID = 0;

	// シェーダーに渡すしきい値の実数
	private float _DiscardValue = 0.0f;

	// 描画するオブジェクトを取得
	GameObject Obj = null;

	/// <summary>
	/// 開始時
	/// </summary>
	void Start ()
	{
		// シェーダーに渡す際のIDを受け取り、登録する
		if (material) {
			DiscardValueID = Shader.PropertyToID ("_DiscardValue");
		}

		// 自身を取得
		Obj = gameObject;
	}

	/// <summary>
	/// 更新
	/// </summary>
	void Update ()
	{
		// しきい値を変化させる(ここでは0.0f〜1.0fの間で調整)
		_DiscardValue = (Mathf.Sin (Time.time) + 1.0f) / 2.0f;

		// シェーダーに値を渡す
		if (material) {
			material.SetFloat (DiscardValueID, _DiscardValue);
		}

		// オブジェクトの座標の更新
		if (Obj) {
			//float x = Mathf.Sin (Time.time) * 0.5f;
			float y = Mathf.Cos (Time.time) * 1.5f;
			//float z = Mathf.Sin (Time.time) * 0.01f;

			Vector3 updatePos = Vector3.zero;
			//updatePos.x = x;
			updatePos.y = 3 + y;
			//updatePos.z = Obj.transform.position.z + z;
			Obj.transform.position = updatePos;
		}
	}
}
