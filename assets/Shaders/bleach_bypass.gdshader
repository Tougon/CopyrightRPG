shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float desaturate_amount : hint_range(0.0, 1.0) = 0.55;
uniform float contrast_level : hint_range(0.0, 10.0) = 1.3;
uniform float desaturate_minimum : hint_range(0.0, 1.0) = 0.5;
uniform float black_white_level : hint_range(0.0, 1.0) = 0.5;
uniform float final_amount : hint_range(0.0, 1.0) = 1.0;
uniform vec4 tint_color : source_color = vec4(1,1,1,1);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.0;

//---------------------------------------------
//fragment
//---------------------------------------------
void fragment() {
	vec4 c = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	vec3 desat = mix(vec3(lum), c.rgb, desaturate_amount);
	desat = (desat - black_white_level) * contrast_level + desaturate_minimum;
	desat = mix(desat, desat * tint_color.rgb, tint_amount);
	COLOR = mix(c, c * vec4(clamp(desat, 0.0, 1.0), 1.0), final_amount);
}