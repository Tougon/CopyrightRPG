shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D height_Map : source_color; // Height Map ( Gradient Field )
uniform vec2 uv_Add = vec2(0.0, 0.0);
uniform float uv_Mul = 1.2;
uniform vec4 modulate : source_color;
uniform float x_buffer = 2.0;
uniform float y_buffer = 1.0;
uniform float time = 11.0;
uniform float N_dot = 32.0;
varying vec2 input;
varying float intensity; 

void vertex() {	
	VERTEX.x *= x_buffer; 
	VERTEX.y *= y_buffer;
}

void fragment() {
	input.x = 3.0 * cos((time - 18.0) * 3.14 / 12.0);
	input.y = 2.0 * (sin((time - 18.0) * 3.14 / 12.0) + 1.0);
	intensity = clamp(cos((time - 12.0) * 3.14 / 12.0), 0.0, 1.0);
	
	vec2 uv_Origin = UV * 2.0 - 1.0;	
	uv_Origin.x *= x_buffer;
	uv_Origin.x /= 1.0;
	uv_Origin.y *= y_buffer;
	uv_Origin.y /= 1.0;                  
	uv_Origin = (uv_Origin + 1.0) / 2.0; 
	//COLOR = texture(TEXTURE, uv_Origin); //FOR ORIGINAL IMAGE DEBUGGING

	vec2 uv_Trans = uv_Origin;
	uv_Trans.x += 0.15 * input.x;
	uv_Trans.y -= 0.1 * input.y;  
	
	float val = texture(height_Map, uv_Trans * uv_Mul + uv_Add).r;
	vec2 uv_Final = uv_Origin * val + uv_Trans * (1.0 - val);
	
	vec2 t = uv_Origin * texture(height_Map, uv_Origin).r + uv_Final * (1.0 - texture(height_Map, uv_Origin).r);
	uv_Final.x = floor(uv_Final.x * N_dot) / N_dot + 0.5 * TEXTURE_PIXEL_SIZE.x; 
	uv_Final.y = floor(uv_Final.y * N_dot) / N_dot + 0.5 * TEXTURE_PIXEL_SIZE.y;

	vec4 shadow = vec4(modulate.rgb, texture(TEXTURE, uv_Final).a) * intensity * val; 
	vec4 col = texture(TEXTURE, uv_Origin);
	
	COLOR = shadow;//mix(shadow, col, col.a);
	//COLOR = texture(height_Map, uv_Trans * uv_Mul + uv_Add); //FOR HEIGHT MAP ( GRADIENT FIELD ) DEBUGGING
}