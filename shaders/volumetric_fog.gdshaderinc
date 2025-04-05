#include "util.gdshaderinc"

#ifndef VOLUMETRIC_FOG
#define VOLUMETRIC_FOG

global uniform float fog_density;
global uniform float fog_light_density;
global uniform float fog_plane;
global uniform vec4 fog_base_color;
global uniform vec4 fog_light_color;
global uniform float fog_light_intensity;
global uniform float fog_ray_max_depth;
global uniform int fog_ray_sample_count;
global uniform float fog_ray_sample_curve;

global uniform sampler3D fog_light_shaft_texture : filter_linear;

vec4 volumetric_fog(vec3 frag_pos, vec3 ray_pos, float ray_offset) {
	float ray_dist = distance(ray_pos, frag_pos);
	vec3 ray_dir = (frag_pos - ray_pos) / ray_dist;
	bool ray_above_plane = ray_pos.y > fog_plane;
	bool frag_above_plane = frag_pos.y > fog_plane;

	float fog_thickness = 0.0;
	float fog_light = 0.0;

	if (!frag_above_plane || !ray_above_plane) {
		vec3 sample_pos = ray_pos;
		vec3 sample_dir = ray_dir;
		float inv_fog_ray_sample_count = 1.0 / float(fog_ray_sample_count);
		float ray_depth = min(fog_ray_max_depth, ray_dist);
		for (int i = 0; i < fog_ray_sample_count; i++) {
			float depth_frac = pow(max(0.0, float(i) - ray_offset) * inv_fog_ray_sample_count, fog_ray_sample_curve);
			float depth_frac_next = pow((float(i + 1) - ray_offset) * inv_fog_ray_sample_count, fog_ray_sample_curve);
			float step_size = ray_depth * (depth_frac_next - depth_frac);
			sample_pos += step_size * sample_dir;
			if (sample_pos.y <= fog_plane) {
				float distance_to_top = fog_plane - sample_pos.y;
				float new_thickness = step_size;
				fog_thickness += new_thickness * 0.5;
				float fog_transmittance = exp(-fog_thickness * fog_density);
				float fog_light_shaft = remap01_clamp(depth_frac, 1.0, 0.8) * remap01_clamp(texture(fog_light_shaft_texture, vec3(sample_pos.xz * 0.003 + TIME * vec2(-0.01), mod(TIME * 0.05, 1.0))).r * 5.0 - 3.0, 0.6, 0.8);
				float sun_transmittance = exp(-distance_to_top * fog_light_density * max(0.5, 1.0 - fog_light_shaft));//1.0 - pow(1.0 - remap01(distance_to_top, fog_plane_top - fog_plane_bottom, 0.0), 2.0);
				fog_light += sun_transmittance * fog_transmittance * step_size;
				fog_thickness += new_thickness * 0.5;
			}
		}

		fog_light = min(1.0, fog_light * 0.25);
	}

	if (!frag_above_plane && !ray_above_plane) {
		float new_thickness = max(0.0, ray_dist - fog_ray_max_depth);
		fog_thickness += new_thickness;
		float distance_to_top = fog_plane - (ray_pos.y + ray_dir.y * new_thickness);
		float sun_transmittance = exp(-distance_to_top * fog_light_density);
		fog_light += sun_transmittance * exp(-fog_thickness * fog_density) * new_thickness;
	} else if (frag_above_plane && !ray_above_plane) {
		float inv = abs(ray_dir.y) > 1e-5 ? -1.0 / ray_dir.y : 1e10;
		float t = (ray_pos.y - fog_plane) * inv;
		vec3 intersection = ray_pos + t * ray_dir;
		ray_dist = distance(ray_pos, intersection);
		float new_thickness = max(0.0, ray_dist - fog_ray_max_depth);
		fog_thickness += new_thickness;
		float distance_to_top = fog_plane - (ray_pos.y + ray_dir.y * fog_ray_max_depth);
		float sun_transmittance = exp(-distance_to_top * fog_light_density);
		fog_light += sun_transmittance * exp(-fog_thickness * fog_density) * new_thickness;
	}
	
	return vec4(mix(fog_base_color.rgb, fog_light_color.rgb * fog_light_intensity, saturate(fog_light)), 1.0 - exp(-fog_thickness * fog_density));
}

vec4 simple_fog(vec3 frag_pos, vec3 ray_pos) {
	float ray_dist = distance(ray_pos, frag_pos);
	return vec4(fog_base_color.rgb, 1.0 - exp(-ray_dist * fog_density));
}

#endif
