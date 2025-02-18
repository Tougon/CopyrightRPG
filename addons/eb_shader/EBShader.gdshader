/*
Earthbound battle backgrounds shader with scrolling effect and palette cycling like in the original game.
@retr0_dev

Apply the shader to a TextureRect or a Sprite. Use a texture with some shapes in a transparent background for best results.
You can then use a ColorRect or another method to paint the background.
You can use the shader on multiple TextureRects and obtain a double-buffer effect tweaking the values for each one, remember to Make Unique the shader material.
*/
shader_type canvas_item;

uniform float screen_height = 640.0;
uniform float amplitude = 0.075;
uniform float frequency = 10.0;
uniform float speed = 2.0;
uniform float amplitude_vertical = 0.0;
uniform float frequency_vertical = 0.0;
uniform float speed_vertical = 0.0;
uniform vec2 scroll_direction = vec2(0.0, 0.0);
uniform float scrolling_speed = 0.08;
uniform bool enable_palette_cycling = false;
uniform bool enable_scan_lines = true;
uniform int scan_line_mod = 2;
uniform sampler2D palette;
uniform float palette_speed = 0.1;
uniform bool enable_pixelate = false;
uniform int pixel_size : hint_range(4, 1080) = 96;

uniform sampler2D transition_palette;
uniform float transition = 1.0;

uniform float time_offset = 0.0;
uniform float time_scale = 1.0;
uniform bool use_manual_time = false;
uniform float manual_time;

void fragment()
{
	vec2 uv = UV;
	float time = (TIME * time_scale) + time_offset;
	
	if (use_manual_time)
	{
		time = (manual_time * time_scale) + time_offset;
	}

	if (enable_pixelate)
	{
		float pixel = float(pixel_size);

		if (pixel < 4.0)
		{
			pixel = 4.0;
		}

		uv.x = floor(uv.x * pixel);
		uv.y = floor(uv.y * pixel);

		uv = uv / pixel;
	}

	float diff_x = amplitude * sin((frequency * UV.y) + (speed * time));
	float diff_y = amplitude_vertical * sin((frequency_vertical * UV.y)  + (speed_vertical * time));
	vec2 scroll = scroll_direction * time * scrolling_speed;
	vec4 tex = texture(TEXTURE, vec2(uv.x + diff_x, uv.y + diff_y) + scroll);
	float palette_swap = mod(tex.r - (time * palette_speed), 1.0);

	if (enable_palette_cycling)
	{
		vec4 transition_palette_sample = texture(transition_palette, vec2(palette_swap, 0));
		vec4 palette_sample = texture(palette, vec2(palette_swap, 0));
		vec4 palette_final = mix(transition_palette_sample, palette_sample, transition);
		COLOR = vec4(palette_final.rgb, tex.a * palette_final.a);
	}
	else COLOR = tex;

	int scan_line = int(UV.y * screen_height) % scan_line_mod;

	if (enable_scan_lines && scan_line == 0) COLOR = mix(vec4(0.0), COLOR, 0.95);
}