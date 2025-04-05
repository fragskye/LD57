#include "util.gdshaderinc"

#ifndef VOLUMETRIC_FOG
#define VOLUMETRIC_FOG

global uniform float fog_density;
global uniform float fog_top_density_falloff;
global uniform float fog_light_density;
global uniform float fog_plane_bottom;
global uniform float fog_plane_top;
global uniform vec4 fog_base_color;
global uniform vec4 fog_light_color;
global uniform float fog_light_intensity;
global uniform float fog_ray_max_depth;
global uniform int fog_ray_sample_count;
global uniform float fog_ray_sample_curve;

global uniform sampler2D fog_texture : filter_linear;

vec4 volumetric_fog(vec3 frag_pos, vec3 ray_pos) {
	float ray_dist = distance(ray_pos, frag_pos);
	vec3 ray_dir = (frag_pos - ray_pos) / ray_dist;
	bool ray_above_top = ray_pos.y > fog_plane_top;
	bool frag_above_top = frag_pos.y > fog_plane_top;
	
	float fog_thickness = 0.0;
	float fog_light = 0.0;
	
	if (!frag_above_top || !ray_above_top) {
		vec3 sample_pos = ray_pos;
		vec3 sample_dir = ray_dir;
		float sample_depth = 0.0;
		float inv_fog_ray_sample_count = 1.0 / float(fog_ray_sample_count);
		float inv_fog_top_density_falloff = 1.0 / fog_top_density_falloff;
		float ray_depth = min(fog_ray_max_depth, ray_dist);
		for (int i = 0; i < fog_ray_sample_count; i++) {
			float depth_frac = pow(float(i) * inv_fog_ray_sample_count, fog_ray_sample_curve);
			float depth_frac_next = pow(float(i + 1) * inv_fog_ray_sample_count, fog_ray_sample_curve);
			float step_size = ray_depth * (depth_frac_next - depth_frac);
			sample_pos += step_size * sample_dir;
			float frac = remap01(sample_pos.y, fog_plane_bottom, fog_plane_top);
			float sample = texture(fog_texture, sample_pos.xz * 0.001 + TIME * vec2(0.01)).r;
			float sample_world_height = mix(fog_plane_bottom, fog_plane_top, sample);
			if (frac <= sample) {
				float distance_to_top = sample_world_height - sample_pos.y;
				float density_falloff = saturate(distance_to_top * inv_fog_top_density_falloff);
				float new_thickness = step_size * density_falloff;
				fog_thickness += new_thickness * 0.5;
				// the falloff section of the density is not calculated accurately here, you'd want to calculate or raymarch that too, but it's close enough and more performant
				float fog_transmittance = exp(-fog_thickness * fog_density);
				float sun_transmittance = exp(-distance_to_top * fog_light_density);//1.0 - pow(1.0 - remap01(distance_to_top, fog_plane_top - fog_plane_bottom, 0.0), 2.0);
				fog_light += sun_transmittance * fog_transmittance * step_size * density_falloff;
				fog_thickness += new_thickness * 0.5;
				if (sample_pos.y > fog_plane_top) {
					break;
				}
			}
			sample_depth += step_size;
		}
		
		fog_light = min(1.0, fog_light * 0.25);
	}
	//return vec4(vec3(0.015, 0.011, 0.01) + vec3(fog_light * 0.04), 1.0 - exp(-fog_thickness * fog_density));
	//return vec4(fog_base_color.rgb + fog_light_color.rgb * fog_light * fog_light_intensity, 1.0 - exp(-fog_thickness * fog_density));
	return vec4(mix(fog_base_color.rgb, fog_light_color.rgb * fog_light_intensity, saturate(fog_light)), 1.0 - exp(-fog_thickness * fog_density));
	//return vec4(fog_light, 0.0, 0.0, 1.0 - exp(-fog_thickness * fog_density));
	//return vec4(fog_light, 0.0, 1.0 - exp(-fog_thickness * fog_density), 1.0);
	//return vec4(0.0, 0.0, 1.0 - exp(-fog_thickness * fog_density), 1.0);
}

vec4 simple_fog(vec3 frag_pos, vec3 ray_pos) {
	float ray_dist = distance(ray_pos, frag_pos);
	return vec4(fog_base_color.rgb, 1.0 - exp(-ray_dist * fog_density));
}

#endif
