using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// バンプマップシェーダーへの値を渡す
/// バンプマップシェーダーをアタッチしたマテリアルを実装しているオブジェクトにアタッチすること
/// </summary>
public class BumpMap : MonoBehaviour
{
	// バンプマップシェーダーをアタッチしたマテリアル
	[SerializeField]
	private Material bumpMaterial;

	// ライトのポジション
	[SerializeField]
	private Transform lightTransform;

	private int lightTransID;

	/// <summary>
	/// 開始時
	/// </summary>
	void Start ()
	{
		// シェーダーに値を渡す際のIDを受け取り、それぞれ登録する
		if (bumpMaterial) {
			lightTransID = Shader.PropertyToID ("light_pos");
		}	
	}

	/// <summary>
	/// レンダリング直前に呼び出される関数
	/// </summary>
	public void OnWillRenderObject ()
	{
		// ライトの座標を取得
		Vector4 lightPos = lightTransform.position;

		// シェーダーに値を渡す
		bumpMaterial.SetVector (lightTransID, lightPos);
	}
}
