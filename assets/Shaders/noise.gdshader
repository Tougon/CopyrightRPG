shader_type canvas_item;

uniform vec4 color_primary : source_color;
uniform vec4 color_secondary : source_color;
uniform vec2 resolution;

float random(vec2 uv, float time) {
	return fract(sin(dot(uv, vec2(12.345 * time, 67.890 * time))) * (12345.67890 + time));
}


void fragment() {
	vec2 uv = UV;
	uv.x = round(uv.x * resolution.x) / resolution.x;
	uv.y = round(uv.y * resolution.y) / resolution.y;

	float noise = random(uv, TIME);
	vec4 color = mix(color_primary, color_secondary, noise);

	COLOR = color;
}
