shader_type canvas_item;

uniform vec2 origin;
//uniform bool falloff_y;
uniform sampler2D falloff_mask;
uniform int active_zlights : hint_range(0, 8) = 0;

// For now, we'll cap to 8 lights max.
// There's no way we'll ever need this many.
uniform vec2 light_origins[8];
uniform bool light_is_circle[8];
uniform vec2 light_size[8];
uniform vec4 light_color[8] : source_color;
uniform float light_energy[8];
uniform vec2 light_falloff[8];

// Parameters for outlines
uniform vec4 line_color : source_color = vec4(0.184, 0.208, 0.227, 1);
uniform float line_thickness : hint_range(0, 20) = 0.3;
uniform bool add_margins = true;

varying vec4 vertex_color; 


bool is_in_bounds(vec2 coord, vec2 center, vec2 size){
	return coord.x >= center.x - size.x && coord.x <= center.x + size.x && coord.y >= center.y - size.y && coord.y <= center.y + size.y;
}


vec2 determine_falloff_direction(vec2 coord, vec2 center, vec2 size){
	vec2 result = vec2(0.0, 0.0);
	
	if (coord.x < center.x - size.x){
		result.x = -1.0;
	}
	
	if (coord.x > center.x + size.x){
		result.x = 1.0;
	}
	
	if (coord.y < center.y - size.y){
		result.y = -1.0;
	}
	
	if (coord.y > center.y + size.y){
		result.y = 1.0;
	}
	
	return result;
}


float energy_for_coord_rect(vec2 coord, int light_index){
	vec2 center = light_origins[light_index];
	vec2 size = light_size[light_index] * 0.5;
	vec2 falloff_size = light_falloff[light_index] * 0.5;

	// Check if coord is in bounds
	if (is_in_bounds(coord, center, size)){
		// Check if coord is in the falloff range
		if (is_in_bounds(coord, center, falloff_size)){
			// If not, use the full strength of the light
			return light_energy[light_index];
		}
		else{
			// Initialize values
			float falloff = 1.0;
			float percent = 0.0;
			
			vec2 dir = determine_falloff_direction(coord, center, falloff_size);//normalize(coord - center);
			
			// Get the distances from the falloff point
			vec2 pos = (coord - center) - (falloff_size * dir);
			vec2 limit = (size * dir) - (falloff_size * dir);
			
			// Calculate percentage based on the axis
			if (abs(dir.x) > abs(dir.y)){
				percent = pos.x / limit.x;
			}
			else if (abs(dir.y) > abs(dir.x)){
				percent = pos.y / limit.y;
			}
			else{
				percent = max(pos.x / limit.x, pos.y / limit.y);
			}
			
			// Invert percent
			falloff -= abs(percent);
			
			// Clamp value, modify, and return
			return clamp(falloff, 0, 1) * light_energy[light_index];
		}
	}
	else{
		// If we are not in a valid X range, never apply light
		return 0.0;
	}
}


float energy_for_coord_circle(vec2 coord, int light_index){
	float dist = distance(coord, light_origins[light_index]);

	// Check if coord is within the radius
	if (dist < light_size[light_index].x){
		if (dist < light_falloff[light_index].x){
			return light_energy[light_index];
		}
		else{
			float pos = dist - light_falloff[light_index].x;
			float limit = light_size[light_index].x - light_falloff[light_index].x;

			float percent = pos / limit;
			float falloff = 1.0 - percent;

			// Clamp value, modify, and return
			return clamp(falloff, 0, 1) * light_energy[light_index];
		}
		return 0.0;
	}
	else{
		// If we are outside the radius, never apply light
		return 0.0;
	}
}


float energy_for_coord(vec2 coord, int light_index){
	return light_is_circle[light_index] ? energy_for_coord_circle(coord, light_index) : energy_for_coord_rect(coord, light_index);
}


void light() {
	bool falloff_y = false;
	vec4 falloff_tex = texture(falloff_mask, UV);

	if (falloff_tex == vec4(1.0, 1.0, 1.0, 1.0)){
		falloff_y = true;
	}

	vec2 coord = FRAGCOORD.xy;
	if (!falloff_y)
		coord.y = origin.y;

	// Calculate light energy modifiers based on total light count
	float total_light_energy = LIGHT_ENERGY;
	for (int i=0; i<active_zlights; i++)
	{
		total_light_energy += energy_for_coord(coord, i);
	}

	float energy_modifier = 0.0;
	if (total_light_energy != 0.0)
	{
		energy_modifier = 1.0 / sqrt(total_light_energy);
	}

	// Calculate lighting using the base light of the scene
	vec4 final_light_color = (LIGHT_COLOR * (LIGHT_ENERGY * energy_modifier));

	// Modify light color using the values of each effecting light
	for (int i=0; i<active_zlights; i++)
	{
		float energy = energy_for_coord(coord, i);
		if (energy > 0.0)
			final_light_color += (light_color[i] * (energy * energy_modifier));
	}

	// Apply lighting values
	LIGHT = vec4(final_light_color.rgb * COLOR.rgb, final_light_color.a);
}

void vertex() {
    if (add_margins) {
        VERTEX += (UV * 2.0 - 1.0) * line_thickness;
    }
	vertex_color = COLOR;
}

void fragment() {
	vec2 uv = UV;
    
    if (add_margins) {
        vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(line_thickness * 2.0));
        
        uv = (uv - texture_pixel_size * line_thickness) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
        
        if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
            COLOR.a = 0.0;
        } else {
            COLOR = texture(TEXTURE, uv);
        }
    } else {
        COLOR = texture(TEXTURE, uv);
    }
    
    vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
    
    if (line_thickness < 0.1) {
        vec4 color = texture(TEXTURE, uv);
        COLOR = color;
    } else {
        float outline = texture(TEXTURE, uv + vec2(-size.x, 0)).a;
        outline += texture(TEXTURE, uv + vec2(0, size.y)).a;
        outline += texture(TEXTURE, uv + vec2(size.x, 0)).a;
        outline += texture(TEXTURE, uv + vec2(0, -size.y)).a;
        outline += texture(TEXTURE, uv + vec2(-size.x * 0.866, size.y * 0.5)).a;
        outline += texture(TEXTURE, uv + vec2(-size.x * 0.5, size.y * 0.866)).a;
        outline += texture(TEXTURE, uv + vec2(size.x * 0.866, size.y * 0.5)).a;
        outline += texture(TEXTURE, uv + vec2(size.x * 0.5, size.y * 0.866)).a;
        outline += texture(TEXTURE, uv + vec2(-size.x * 0.866, -size.y * 0.5)).a;
        outline += texture(TEXTURE, uv + vec2(-size.x * 0.5, -size.y * 0.866)).a;
        outline += texture(TEXTURE, uv + vec2(size.x * 0.866, -size.y * 0.5)).a;
        outline += texture(TEXTURE, uv + vec2(size.x * 0.5, -size.y * 0.866)).a;
        outline = min(outline, 1.0);
        
        vec4 color = texture(TEXTURE, uv);
        COLOR = mix(color, line_color, outline - color.a);
    }
	
	COLOR *= vertex_color;
}