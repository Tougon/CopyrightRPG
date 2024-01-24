shader_type canvas_item;

//2D (returns 0 - 1)
float random2d(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float randomRange (in vec2 seed, in float min, in float max) {
		return min + random2d(seed) * (max - min);
}

// return 1 if v inside 1d range
float insideRange(float v, float bottom, float top) {
   return step(bottom, v) - step(top, v);
}

//inputs
uniform float amount = 0.2; //0 - 1 glitch amount
uniform float speed = 0.6; //0 - 1 speed
   
void fragment()
{
    float time = floor(TIME * speed * 60.0);
	vec2 uv = UV;
    
    //copy orig
	vec4 outTex = texture(TEXTURE, uv);
    
    //randomly offset slices horizontally
    float maxOffset = amount/2.0;
    for (float i = 0.0; i < 10.0 * amount; i += 1.0) {
        float sliceY = random2d(vec2(time , 2345.0 + float(i)));
        float sliceH = random2d(vec2(time , 9035.0 + float(i))) * 0.25;
        float hOffset = randomRange(vec2(time , 9625.0 + float(i)), -maxOffset, maxOffset);
        vec2 uvOff = uv;
        uvOff.x += hOffset;
        if (insideRange(uv.y, sliceY, fract(sliceY+sliceH)) == 1.0)
		{
        	outTex = texture(TEXTURE, uvOff);
        }
    }
    
    //do slight offset on one entire channel
    float maxColOffset = amount/6.0;
    float rnd = random2d(vec2(time , 9545.0));
    vec2 colOffset = vec2(randomRange(vec2(time , 9545.0),-maxColOffset,maxColOffset), 
                       randomRange(vec2(time , 7205.0),-maxColOffset,maxColOffset));
    if (rnd < 0.33){
        outTex.r = texture(TEXTURE, uv + colOffset).r;
        
    }
	else if (rnd < 0.66){
        outTex.g = texture(TEXTURE, uv + colOffset).g;
        
    }
	else{
        outTex.b = texture(TEXTURE, uv + colOffset).b;  
    }
       
	COLOR = outTex;
	//COLOR = vec4(uv.x, uv.y, 0, 1);
}
