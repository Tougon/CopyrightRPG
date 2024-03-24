shader_type canvas_item;

uniform vec4 overlay_color: source_color = vec4(1,1,1,1);
uniform float overlay_color_amount = 0.0;
uniform float overlay_alpha_amount = 0.0;
uniform sampler2D overlay_texture: hint_default_white, repeat_enable;
uniform vec2 overlay_texture_offset;
uniform vec2 overlay_texture_tiling = vec2(1.0,1.0);
uniform float overlay_texture_amount = 0.0;


void fragment()
{
	// Cache the sprite alpha, as it will be necessary later.
	float fragment_alpha = COLOR.a;
	// Lerp the overlay color with the original sprite
	vec4 col = mix(COLOR, overlay_color, overlay_color_amount);
	COLOR = col;
	
	// Calculate the texture positioning with the sprite UVs
	vec2 tiling = (UV + (overlay_texture_offset * TIME));
	
	// Tile the texture
	tiling.x *= overlay_texture_tiling.x;
	tiling.y *= overlay_texture_tiling.y;
	
	// Sample the texture
	vec4 tex = texture(overlay_texture, tiling);
	
	// Blend the overlay with the sprite
	COLOR = mix(col, tex, overlay_texture_amount);
	
	// Apply the original sprite alpha mixed with overlay alpha
	COLOR.a = mix(fragment_alpha, overlay_color.a * fragment_alpha, overlay_alpha_amount * overlay_color_amount);;
}
