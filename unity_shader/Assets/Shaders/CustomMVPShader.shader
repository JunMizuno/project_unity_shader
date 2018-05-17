// CustomMVPスクリプトのテストシェーダー(変換行列をCustomMVP.csから受け取る)
Shader "Custom/CustomMVPShader"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform float4x4 mvp_matrix;
			uniform float4x4 mv_matrix;
			uniform float4x4 v_matrix;

			float4 _Color;

			struct app_data
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(app_data IN)
			{
				v2f o;
				o.vertex = mul(mvp_matrix, IN.vertex);
				return o;
			}

			float4 frag(v2f IN) : SV_TARGET
			{
				return _Color;
			}

			ENDCG
		}
	}
}
