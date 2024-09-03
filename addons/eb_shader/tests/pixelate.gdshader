shader_type canvas_item;

uniform int pixel_size : hint_range(4, 1080) = 32;

void fragment() {
	float pixel = float(pixel_size);

	if (pixel < 4.0)
	{
		pixel = 4.0;
	}

	vec2 uv = UV;
	uv.x = floor(uv.x * pixel);
	uv.y = floor(uv.y * pixel);
	uv = uv / pixel;

	vec4 tex = texture(TEXTURE, uv);
	COLOR = tex;
}
