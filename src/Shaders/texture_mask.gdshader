shader_type canvas_item;

//uniform vec4 color: source_color;
uniform sampler2D mask: hint_default_white;
uniform float scale = 2.0;
uniform float threshold = 0.5;
uniform vec2 offset;
const float pivot = 0.5;

void fragment() {
    vec2 ps = SCREEN_PIXEL_SIZE;
    vec2 ratio = vec2(1, 1);//(ps.x > ps.y) ? vec2(ps.y / ps.x, 1) : vec2(1, ps.x / ps.y);
    float a = 1.0 - texture(mask, offset + ((UV - pivot) * scale * ratio + pivot)).a;
    COLOR.a = (a < threshold) ? COLOR.a * a : COLOR.a; // Originally used color.a
    //COLOR.rgb = color.rgb;
}