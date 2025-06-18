shader_type canvas_item;

uniform vec4 baseColor: source_color = vec4(0.3058, 0.835, 0.960, 1.);
uniform float speed = 0.5;
uniform vec4 linesColor: source_color = vec4(0.633232, 0.910156, 0.555693, 1.);
uniform float linesColorIntensity = 5.;
uniform sampler2D hologramTexture;
uniform vec2 hologramTextureTiling = vec2(1., 5.);
uniform float distortion = 1.0;
uniform float stablization = 10.0;
uniform float distortion_speed = 1.0;
uniform float distortion_factor : hint_range(0.0, 1.0) = 0.4;

vec2 tilingAndOffset(vec2 uv, vec2 tiling, vec2 offset) {
    return mod(uv * tiling + offset, 1);
}


vec4 color_shift(in vec2 uv, in sampler2D image, vec2 shift_vector) {
	return texture(image, uv - shift_vector);
}


void fragment() {
	float final_alpha = COLOR.a;
    vec2 offset = vec2(TIME * speed / 100.0);
    vec2 tiling = tilingAndOffset(UV, hologramTextureTiling, offset);

    vec4 noise = texture(hologramTexture, tiling);

    float fresnel = 0.71;
    vec4 colorLines = linesColor * vec4(vec3(linesColorIntensity), 1.0);
    vec4 emission = colorLines * fresnel * noise;

	float smooth_line_grade = abs(sin((UV.y - TIME*distortion_speed) * (distortion * 100.0)));

    vec4 albedo = baseColor;
    float alpha = dot(noise.rgb, vec3(1.0));
    vec4 hologram;
    hologram.rgb = emission.rgb + (1.0 - emission.rgb) * albedo.rgb * albedo.a;
    hologram.a = emission.a + (1.0 - emission.a) * alpha;
    hologram.a = hologram.a + (1.0 - hologram.a) * albedo.a;

	COLOR = color_shift(UV, TEXTURE, vec2(1.0, 0.0)*smooth_line_grade/stablization*distortion_factor);
	float shifted_alpha = COLOR.a;
	//COLOR = texture(TEXTURE, UV);
    COLOR.rgb = COLOR.rgb + (1.0 - COLOR.rgb) * hologram.rgb;
    COLOR.a = final_alpha * hologram.a * shifted_alpha;
}
