shader_type sky;

#include "volumetric_fog.gdshaderinc"

uniform vec3 sky_color: source_color = vec3(0.6, 0.8, 1.0);
uniform float sky_color_intensity = 1.0;

void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
	COLOR = sky_color_intensity * sky_color;
	FOG = volumetric_fog(POSITION + EYEDIR * 1000.0, POSITION);
}
