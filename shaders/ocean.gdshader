shader_type spatial;

render_mode diffuse_lambert_wrap, specular_toon;

const int WAVES = 5;
const vec2 DIRECTIONS[] = {
	vec2(0.1, -1.0),
	vec2(-0.1, -1.0),
	vec2(0.0, -1.0),
	vec2(0.25, -1.0),
	vec2(-0.25, -1.0),
	vec2(0.3, -1.0),
	vec2(0.3, -1.0)
};

uniform vec3 albedo : source_color = vec3(1.0);

uniform sampler2D ocean_detail_texture : filter_linear, repeat_enable, hint_default_black;
uniform sampler2D ocean_detail_normal_texture : filter_linear, repeat_enable, hint_default_black;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

void vertex() {
	float height = 0.0;
	vec3 normal = vec3(0.0);
	for (int wave = 0; wave <= WAVES; wave++) {
		float frequency = 0.1 * pow(1.8, float(wave));
		float amplitude = 0.8 * pow(0.5, float(wave));
		float phase = 0.0 + TIME;
		if (wave < WAVES) {
			// Sum of sines
			vec2 direction = normalize(DIRECTIONS[wave]);
			float coord = dot(VERTEX.xz * frequency, direction) + phase;
			float h = amplitude * sin(coord);
			height += h;
			vec2 n = amplitude * frequency * direction * cos(coord);
			normal += vec3(n.x, 0.0, n.y);
		} else {
			// One additional layer of noise texture
			amplitude = 0.05;
			frequency = 0.01;
			phase *= 0.01;
			vec2 direction = vec2(0.0, -1.0);
			vec2 coord = VERTEX.xz * frequency + direction * phase;
			height += amplitude * texture(ocean_detail_texture, coord).r;
			vec3 detail_normal = texture(ocean_detail_normal_texture, coord).xyz * 2.0 - 1.0;
			normal += 100.0 * amplitude * frequency * vec3(detail_normal.x, 0.0, detail_normal.y);
		}
	}
	VERTEX.y += height;
	NORMAL = normalize(vec3(-normal.x, 1.0, -normal.z));
}

void fragment() {
    float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
	float distance_past_surface = VERTEX.z - pixel_position.z;
	
	float foam = smoothstep(0.4, 0.2, distance_past_surface);
	ALBEDO = mix(albedo, vec3(1.0), foam);
	ROUGHNESS = mix(0.01, 1.0, foam);
	ALPHA = smoothstep(0.0, 0.2, distance_past_surface);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
