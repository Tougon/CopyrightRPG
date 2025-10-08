shader_type canvas_item;

uniform vec4 color_primary : source_color;
uniform vec4 color_secondary : source_color;
uniform vec2 aspect = vec2(1,0.5);
uniform float scale_factor = 1;
uniform float amount = 1;

float random(vec2 uv, float time) {
	return fract(sin(dot(uv, vec2(12.345 * time, 67.890 * time))) * (12345.67890 + time));
}


void fragment() {
	vec2 uv = SCREEN_UV;
	uv.x = round(uv.x * (scale_factor * aspect.x)) / (scale_factor * aspect.x);
	uv.y = round(uv.y * (scale_factor * aspect.y)) / (scale_factor * aspect.y);

	float noise = random(uv, TIME);
	vec4 color = mix(color_primary, color_secondary, noise * amount);

	COLOR = color;
}
