using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// CustomMVPShaderへ変換行列を渡す
/// </summary>
public class CustomMVP : MonoBehaviour
{

	[SerializeField]
	private Material material;

	public void OnWillRenderObject ()
	{
		if (material == null) {
			return;
		}

		Camera renderCamera = Camera.current;

		// オブジェクトにアタッチしている場合はこちら？
		//Matrix4x4 m = gameObject.transform.localToWorldMatrix;

		Matrix4x4 m = GetComponent<Renderer> ().localToWorldMatrix;
		Matrix4x4 v = renderCamera.worldToCameraMatrix;
		Matrix4x4 p = renderCamera.cameraType == CameraType.SceneView ? GL.GetGPUProjectionMatrix (renderCamera.projectionMatrix, true) : renderCamera.projectionMatrix;

		// @memo. 掛け合わせの順番注意
		Matrix4x4 mvp = p * v * m;
		Matrix4x4 mv = v * m;

		// DynamicBatchingによって複数のオブジェクトでマテリアルを共有するとmatrixがオブジェクトごとに作用してくれない。こういった用途ではshaderで素直にUNITY_MATRIXを使うべき
		material.SetMatrix ("mvp_matrix", mvp);
		material.SetMatrix ("mv_matrix", mv);
		material.SetMatrix ("v_matrix", v);
	}
}
