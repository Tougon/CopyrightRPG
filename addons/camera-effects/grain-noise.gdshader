shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

uniform float noise_strength = 50.0;

void fragment() {
    // Readbackground and foreground images.
	vec4 col = texture(SCREEN_TEXTURE, UV);

    float x = (UV.x + 4.0) * (UV.y + 4.0) * (TIME * 10.0);
    vec3 grain = vec3(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01) - 0.005) * noise_strength;

    COLOR = vec4(col.rgb + grain, 1.0);
}
