shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

uniform float noise_strength = 50.0;
uniform float noise_floor : hint_range(0, 1) = 0.01;
uniform bool use_time = true;
uniform vec2 uv_offset = vec2(0,0);
uniform float uv_amount = 0;
uniform vec4 bg_color : source_color = vec4(1,1,1,1);

void fragment() {
	// Generate noise
	float x = use_time ? (UV.x + 4.0) * (UV.y + 4.0) * (TIME * 10.0) : (UV.x + 4.0) * (UV.y + 4.0) * (10.0);
	vec3 noise = vec3(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01) - 0.005) * noise_strength + vec3(noise_floor, noise_floor, noise_floor);
	float noise_len = length(noise);
	float amount = noise_len < noise_floor ? noise_floor : noise_len;

	//vec2 coords = UV;
	//vec2 invrs_coords = vec2(1,1) - UV;
	float y = 1.0 - UV.y;

	vec2 offset = (uv_offset * amount * uv_amount * y);
	//vec2 offset = (uv_offset * uv_amount);

	// Sample texture
	vec4 tex = texture(SCREEN_TEXTURE, UV + offset);
	COLOR = abs(length(UV + offset) * uv_amount) > 0.5 ? bg_color : vec4(tex.rgb, 1.0);
}