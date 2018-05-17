using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// フラットシェーディング(ローポリゴンのように見せる処理)
/// </summary>
public class FlatShadding : MonoBehaviour
{

	void Start ()
	{
		
	}

	void FlatShaddingFunc ()
	{
		MeshFilter mf = GetComponent<MeshFilter> ();
		Mesh mesh = Instantiate (mf.sharedMesh) as Mesh;
		mf.sharedMesh = mesh;

		Vector3[] oldVerts = mesh.vertices;
		int[] triangles = mesh.triangles;
		Vector3[] vertices = new Vector3[triangles.Length];

		for (int i = 0; i < triangles.Length; i++) {
			vertices [i] = oldVerts [triangles [i]];
			triangles [i] = i;
		}

		mesh.vertices = vertices;
		mesh.triangles = triangles;
		mesh.RecalculateNormals ();
	}

	void Update ()
	{
		//※挙動テスト(実際の実装時には連続生成しないようにしなければならない)
		if (Input.GetMouseButtonDown (0)) {
			FlatShaddingFunc ();
		}
	}
}
