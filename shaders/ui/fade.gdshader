shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform vec2 gradient_center = vec2(0.5, 0.5);
uniform vec2 direction = vec2(1.0, 0.0);

void fragment() {
	COLOR = color;
	COLOR.a *= clamp(dot(UV - gradient_center, -direction), 0.0, 1.0);
}
