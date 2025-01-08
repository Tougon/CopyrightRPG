//shader by CasualGarageCoder, updated to Godot 4
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float chaos : hint_range(0., 32.) = 1.;
uniform float radius : hint_range(0., 3.) = 0.5;
uniform float attenuation : hint_range(1., 5.) = 2.;
uniform float saturation : hint_range(0., 1.) = 1.;
uniform vec4 modulate: source_color = vec4(1,1,1,1);
uniform float modulate_amount : hint_range(0., 1.) = 0.;
uniform bool invert = false;
uniform float final_amount : hint_range(0., 1.) = 1.;

uniform bool vignette = false;
uniform float alpha = 1.0;
uniform float inner_radius = 0.0;
uniform float outer_radius = 1.0;

varying vec2 amount_r;
varying vec2 amount_g;
varying vec2 amount_b;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453) - .5;
}

void vertex() {
    vec2 shifted_uv = (UV * 2.) - 1.;
    amount_r = normalize(
        vec2(rand(TIME * 1.3 * shifted_uv),
        rand(TIME * 1.64 * shifted_uv)));
    amount_g = normalize(
        vec2(rand(TIME * 1.5 * shifted_uv),
        rand(TIME * 1.7 * shifted_uv)));
    amount_b = normalize(
        vec2(rand(TIME * 1.17 * shifted_uv),
        rand(TIME * 1.23 * shifted_uv)));
}

void fragment() {
    vec2 chaos_v = vec2(chaos, -chaos) * SCREEN_PIXEL_SIZE;

    float dist = length((UV - vec2(0.5)) * 2.);
    float att = clamp(dist / radius, 0., 1.);

    chaos_v *= 1. - pow(att, attenuation);

	float x = abs(UV.r-.5)*2.0;
	float y = abs(UV.g-.5)*2.0;
	float q = 1.0-(1.0-sqrt(x*x+y*y)/outer_radius)/(1.0-inner_radius);

	vec4 screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV);

	float r = texture(SCREEN_TEXTURE, SCREEN_UV + chaos_v * amount_r).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV + chaos_v * amount_g).g;
	float b = texture(SCREEN_TEXTURE, SCREEN_UV + chaos_v * amount_b).b;

	if (invert)
	{
		r = 1. - r;
		g = 1. - g;
		b = 1. - b;
	}

	float max_color = max(r, max(g, b));

	r = mix(max_color * mix(1, modulate.r, modulate_amount), r, saturation);
	g = mix(max_color * mix(1, modulate.g, modulate_amount), g, saturation);
	b = mix(max_color * mix(1, modulate.b, modulate_amount), b, saturation);

	float v = clamp(1.0 - (q * alpha), 0, 1);
	if (!vignette) v = 1.;

    COLOR = mix(screen_tex, vec4(r * v, g * v, b * v, 1.), final_amount);

}