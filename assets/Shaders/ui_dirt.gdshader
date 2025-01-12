shader_type canvas_item;

uniform sampler2D overlay_texture: hint_default_white, repeat_enable;
uniform vec2 overlay_texture_offset;
uniform vec2 overlay_texture_tiling = vec2(1.0,1.0);
uniform float overlay_texture_amount : hint_range(0., 1.) = 1.;
uniform float overlay_radius = 1.;


void vertex() {
	// Called for every vertex the material is visible on.
}


void fragment()
{
	// Cache the sprite alpha, as it will be necessary later.
	float fragment_alpha = COLOR.a;
	// Lerp the overlay color with the original sprite
	vec4 col = COLOR;

	// Calculate the texture positioning with the sprite UVs
	vec2 tiling = (UV + (overlay_texture_offset));

	// Tile the texture
	tiling.x *= overlay_texture_tiling.x;
	tiling.y *= overlay_texture_tiling.y;

	// Sample the texture
	vec4 tex = texture(overlay_texture, tiling);

	vec2 uv = UV;
	uv.x -= 0.5;
	uv.y -= 0.5;

	float len = length(uv);

	// Blend the overlay with the sprite
	vec4 overlay = mix(col, tex, sin(overlay_texture_amount));
	COLOR = mix(col, overlay, len - overlay_radius);
	//COLOR = mix(col, tex, 1.0 - tex_amount);
	//COLOR = mix(col, tex, sin(overlay_texture_amount));

	// Apply the original sprite alpha mixed with overlay alpha
	COLOR.a = col.a;//col.a;
}