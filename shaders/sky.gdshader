shader_type sky;

#include "shared_global_uniforms.gdshaderinc"
#include "volumetric_fog.gdshaderinc"

uniform vec3 sky_color: source_color = vec3(0.6, 0.8, 1.0);
uniform float sky_color_intensity = 1.0;

void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
	COLOR = sky_color_intensity * sky_color;
	#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	float ray_offset = texture(value_noise_texture, SKY_COORDS * 4.0).w;
	#else
	float ray_offset = texture(value_noise_texture, SCREEN_UV).w;
	#endif
	FOG = volumetric_fog(POSITION + EYEDIR * 1000.0, POSITION, ray_offset);
}
