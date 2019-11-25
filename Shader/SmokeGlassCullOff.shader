Shader "VRCSmokeGlass/SmokeGlassStandardCullOff"
{
	Properties
	{
		_MainTex("SmokeRenderTexture (Specified Value)", 2D) = "white" {}
		_Cloudiness("Cloudiness", Range(0,1)) = 0.2
		_FrontTex("Front Tex", 2D) = "white" {}
		_FrontTexPower("Front Tex Power", Range(0,1)) = 1
		_NormalTex("Normal", 2D) = "bump" {}
		_MaskWidth("Mask Width", Range(0, 1)) = 0
		_MaskHeight("Mask height", Range(0, 1)) = 0
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}

	SubShader
	{
		ZWrite On
		Cull Off

		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}

		CGPROGRAM
			#pragma surface surf Standard alpha:fade

			struct Input
			{
				float2 uv_MainTex;
				float2 uv_FrontTex;
				float2 uv_NormalTex;
			};

			sampler2D _MainTex;
			sampler2D _FrontTex;
			sampler2D _NormalTex;
			float _Cloudiness;
			float _MaskWidth;
			float _MaskHeight;
			float _FrontTexPower;
			half _Glossiness;
			half _Metallic;

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				fixed4 render_tex = tex2D(_MainTex, IN.uv_MainTex);
				fixed4 front_tex = tex2D(_FrontTex, IN.uv_FrontTex);

				float in_mask_region = abs(1. - IN.uv_MainTex.x) > _MaskWidth && abs(1. - IN.uv_MainTex.y) > _MaskHeight;

				// Cloudinessはアルファ値のオフセットとして機能する（テクスチャ指定しなくても曇りガラスとして使えるように）
				float tex_alpha = min((front_tex.a * _FrontTexPower) + _Cloudiness, 1.f);
				float alpha = in_mask_region
					? min(tex_alpha * render_tex.b, tex_alpha)
					: 0.f;
				float3 normal = in_mask_region ? UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex))  : float3(0.f, 0.f, 0.f);

				o.Albedo = front_tex.rgb;
				o.Alpha = alpha;
				o.Normal = normal;
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
			}
		ENDCG
	}
	CustomEditor "SGStandardEditor"
}