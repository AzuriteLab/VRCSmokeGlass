Shader "VRCSmokeGlass/Writer/SGHitBufferWriter"
{
	Properties
	{
		_tex("Render Texture", 2D) = "white" {}
		_tolerance("Tolerance", Range(0.0, 1.0)) = 0.99
		[Toggle] _using_blur("Using blur", float) = 0.0
		[Toggle] _enable_restoration("Enable return from wipe", float) = 0.0
		[Toggle] _reset("Reset", float) = 0.0
		_restoration_resolution("Return from wipe resolution", float) = 0.002
		_restoration_speed("Return from wipe speed", range(1, 10)) = 4
		[Enum(Linear, 0.0, Hermite, 1.0)] _interpolate_type("Interpolation type", float) = 0.0
		_hermite_left_point("Hermite left point", range(0.0, 1.0)) = 0.1
		_hermite_right_point("Hermite right point", range(0.0, 1.0)) = 0.9
	}

	SubShader
	{
		ZWrite Off

		Pass
		{
			Name "UPDATE"
			CGPROGRAM
				#include "UnityCustomRenderTexture.cginc"
				#pragma vertex CustomRenderTextureVertexShader
				#pragma fragment frag

				sampler2D _tex;
				float _tolerance;
				float _restoration_resolution;
				float _using_blur;
				float _reset;
				float _enable_restoration;
				int _restoration_speed;
				float _interpolate_type;
				float _hermite_left_point;
				float _hermite_right_point;

				float4 _tex_TexelSize;

				float4 frag(v2f_customrendertexture i) : SV_Target
				{
					float2 uv = i.localTexcoord;
					float2 depth_uv = float2(1. - uv.x, uv.y);

					float4 prev_tex = tex2D(_SelfTexture2D, i.localTexcoord.xy);

					// write frame count (g: memory)
					int frame =
						(int(prev_tex.g * 255.) << 0);
					frame = frame + 1;
					prev_tex.g = ((frame >> 0) & 0xff) / 255.;

					// apply blur effect if enabled `Using blur` checkbox
					prev_tex.r =
						(_using_blur == 1.) ?
						(
							prev_tex.r +
							tex2D(_SelfTexture2D, uv.xy + float2(_tex_TexelSize.x, 0.)).r +
							tex2D(_SelfTexture2D, uv.xy - float2(_tex_TexelSize.x, 0.)).r +
							tex2D(_SelfTexture2D, uv.xy + float2(0., _tex_TexelSize.y)).r +
							tex2D(_SelfTexture2D, uv.xy - float2(0., _tex_TexelSize.y)).r
						) / 5. : prev_tex.r;

					// write hit effect (r: temporary , b: final cloudiness)
					float4 current_tex = tex2D(_tex, depth_uv);
					current_tex.r = step(_tolerance, current_tex.r);
				
					float cloudiness_linear = saturate(prev_tex.r - _restoration_resolution * _enable_restoration);
					cloudiness_linear = fmod(frame, floor(_restoration_speed)) == 0. ? cloudiness_linear : prev_tex.r;

					float cloudiness_hermite = smoothstep(_hermite_left_point, _hermite_right_point, abs(1. - cloudiness_linear));
					
					prev_tex.r = (cloudiness_linear + current_tex.r) * abs(1. - _reset);
					prev_tex.b = (cloudiness_hermite * _interpolate_type) + (lerp(1., 0., cloudiness_linear) * abs(1. - _interpolate_type));

					return prev_tex;
				}
			ENDCG
		}
	}
	CustomEditor "SGHitBufferWriterEditor"
}
