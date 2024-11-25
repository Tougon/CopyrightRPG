shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

uniform float noise_size = 1.0;
uniform float noise_strength = 1.0;
uniform vec2 noise_magnitude = vec2(1, 0.333);
uniform float noise_floor : hint_range(0, 1) = 0.01;
uniform bool use_time = true;
uniform vec2 aspect_ratio = vec2(1,1.333);
uniform float uv_amount = 0;
uniform vec4 bg_color : source_color = vec4(1,1,1,1);
uniform vec2 origin = vec2(0.5,0.5);


float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898,78.233))) * 43758.5453123);
}


void fragment() {
	// Map the location of the iris effect
	vec2 clamp_origin = vec2(clamp(origin.x, 0.0, 1.0), clamp(origin.y, 0.0, 1.0));
	vec2 inv_origin = vec2(1.0 - clamp_origin.x, 1.0 - clamp_origin.y);
	vec2 adjusted = (UV - clamp_origin);
	
	float x_sign = UV.x < clamp_origin.x ? 1.0 : -1.0;
	float y_sign = UV.y < clamp_origin.y ? 1.0 : -1.0;
	x_sign = x_sign / aspect_ratio.y;
	y_sign = y_sign / aspect_ratio.x;
	
	vec2 to_origin = vec2(abs(adjusted.x), abs(adjusted.y));
	
	if (UV.x < clamp_origin.x) to_origin = vec2(to_origin.x / clamp_origin.x, to_origin.y);
	else to_origin = vec2(to_origin.x / inv_origin.x, to_origin.y);
	
	if (UV.y < clamp_origin.y) to_origin = vec2(to_origin.x, to_origin.y / clamp_origin.y);
	else to_origin = vec2(to_origin.x, to_origin.y / inv_origin.y);
	
	to_origin = vec2(clamp(to_origin.x, 0.0, 1.0) / aspect_ratio.x, clamp(to_origin.y, 0.0, 1.0) / aspect_ratio.y);
	
	vec2 relative = origin + adjusted;
	
	float origin_scaler = length(to_origin);
	
	// Generate noise
	float rand = use_time ? random(UV * TIME) : random(UV);
	vec4 noise = vec4(rand, rand, rand, 1);

	// Sample texture
	vec2 direction = vec2(x_sign, y_sign);
	vec2 uv_offset = ((noise_magnitude) * uv_amount * (rand * noise_strength)) * direction * to_origin;
	vec2 sample_coord = UV + uv_offset;
	
	vec4 tex = texture(SCREEN_TEXTURE, sample_coord); // + offset
	tex = vec4(tex.r, tex.g, tex.b, 1);//vec4(to_origin.r + uv_offset.x, to_origin.g + uv_offset.y, 0.0, 1.0);
	
	COLOR = mix(tex, mix(tex, bg_color, (1.0 - origin_scaler) + uv_amount), clamp(uv_amount - 0.5, 0.0, 1.0));
}