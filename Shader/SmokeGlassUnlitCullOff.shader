Shader "VRCSmokeGlass/SmokeGlassUnlitCullOff"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Cloudiness("Cloudiness", Range(0,1)) = 0.2
		_FrontTex("Front Texture", 2D) = "white" {}
		_FrontTexPower("Front Tex Power", Range(0,1)) = 1
		_MaskWidth("Mask Width", Range(0, 1)) = 0
		_MaskHeight("Mask height", Range(0, 1)) = 0
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		Cull Off
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv_FrontTex : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _FrontTex;
			float _Cloudiness;
			float _MaskWidth;
			float _MaskHeight;
			float _FrontTexPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv_FrontTex = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 render_tex = tex2D(_MainTex, i.uv);
				fixed4 front_tex =  tex2D(_FrontTex, i.uv_FrontTex);

				float in_mask_region = abs(1. - i.uv.x) > _MaskWidth && abs(1. - i.uv.y) > _MaskHeight;

				// Cloudinessはアルファ値のオフセットとして機能する（テクスチャ指定しなくても曇りガラスとして使えるように）
				float tex_alpha = min((front_tex.a * _FrontTexPower) + _Cloudiness, 1.f);
				float alpha = in_mask_region
					? min(tex_alpha * render_tex.b, tex_alpha)
					: 0.f;
				float4 col = front_tex.rgba;
				col.a = alpha;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	CustomEditor "SGUnlitEditor"
}
