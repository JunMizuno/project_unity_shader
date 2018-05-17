using UnityEngine;

/// <summary>
/// 影の深度をチェック及びシェーダーに渡す
/// </summary>

// これ↓をコメントアウトすると実行せずとも編集するごとに処理が走ります
//[ExecuteInEditMode]
public class ShadowCamera : MonoBehaviour
{
	// マテリアル
	[SerializeField] Material material;

	// オブジェクト表示がある場合、カメラ毎に呼び出される関数(カメラの台数分通ることになる？)
	void OnWillRenderObject ()
	{
		//Debug.Log ("カメラ識別:" + Camera.current.name);

		// DirectionalLightにアタッチしたライトの取得
		var cam = Camera.current;

		// ライトにくっつけたカメラを利用してライトから見たDepthRenderTextureに焼き込む
		// ここの名前はヒエラルキーのライトの名前にする(適宜設定のこと)
		if (cam.name == "Directional Light") {
			//Debug.Log ("ライトのカメラ取得");

			// 以下、行列変換
			var lightVMatrix = cam.worldToCameraMatrix;
			var lightPMatrix = GL.GetGPUProjectionMatrix (cam.projectionMatrix, false);
			var lightVP = lightPMatrix * lightVMatrix;

			// (-1,1)を(0,1)に補正する行列
			var biasMat = new Matrix4x4 ();
			biasMat.SetRow (0, new Vector4 (0.5f, 0.0f, 0.0f, 0.5f));
			biasMat.SetRow (1, new Vector4 (0.0f, 0.5f, 0.0f, 0.5f));
			biasMat.SetRow (2, new Vector4 (0.0f, 0.0f, 0.5f, 0.5f));
			biasMat.SetRow (3, new Vector4 (0.0f, 0.0f, 0.0f, 1.0f));

			// ライトから見た射影変換行列をシェーダーに渡す
			material.SetMatrix ("_LightVP", biasMat * lightVP);
		}
	}
}
