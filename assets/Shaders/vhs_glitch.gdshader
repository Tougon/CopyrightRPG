/*
	グリッチ トランジション シェーダー by あるる（きのもと 結衣） @arlez80
	Glitch Transition Shader by Yui Kinomoto @arlez80

	MIT License
*/

shader_type canvas_item;

// 振動の強さ
uniform float shake_power = 0.03;
// 振動ブロックサイズ
uniform float shake_block_size = 30.5;
// 色の分離率
uniform float fade : hint_range( 0.0, 1.0 ) = 0.01;
// R方向
uniform vec2 direction_r = vec2( 1.0, 0.0 );
// G方向
uniform vec2 direction_g = vec2( 0.4, 1.0 );
// B方向
uniform vec2 direction_b = vec2( -0.7, -0.3 );

uniform float modifier_r : hint_range(0.0, 1.0) = 1;
uniform float modifier_g : hint_range(0.0, 1.0) = 1;
uniform float modifier_b : hint_range(0.0, 1.0) = 1;
uniform float saturation : hint_range(0.0, 1.0) = 1;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;


float random( float seed )
{
	return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
}

void fragment( )
{
	vec2 fixed_uv = SCREEN_UV;
	fixed_uv.x += (
		random(
			( trunc( SCREEN_UV.y * shake_block_size ) / shake_block_size )
		+	TIME
		) - 0.5
	) * shake_power * ( fade * 12.0 );

	COLOR = vec4(
		textureLod( screen_texture, fixed_uv + normalize( direction_r ) * fade, 0.0 ).r * modifier_r
	,	textureLod( screen_texture, fixed_uv + normalize( direction_g ) * fade, 0.0 ).g * modifier_g
	,	textureLod( screen_texture, fixed_uv + normalize( direction_b ) * fade, 0.0 ).b * modifier_b
	,	0.0
	) * ( 1.0 - fade );

	 COLOR.rgb = mix(vec3(dot(COLOR.rgb, vec3(0.299, 0.587, 0.114))), COLOR.rgb, saturation);

	COLOR.a = 1.0;
}