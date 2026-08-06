extern vec4 offset;
extern float seed;
extern float amp;
extern vec2 size;

vec2 random(vec2 value){
	value = vec2( dot(value, vec2(127.1,311.7)+seed),
				  dot(value, vec2(269.5,183.3)+seed));
	return -1.0 + 2.0 * fract(sin(value) * 43758.5453123);
}

float seamless_noise(vec2 uv, vec2 _period) {
	uv = uv * 40.;
	vec2 cellsMinimum = floor(uv);
	vec2 cellsMaximum = ceil(uv);
	vec2 uv_fract = fract(uv);
	
	cellsMinimum = mod(cellsMinimum, _period);
	cellsMaximum = mod(cellsMaximum, _period);
	
	vec2 blur = smoothstep(0.0, 1.0, uv_fract);
	
	vec2 lowerLeftDirection = random(vec2(cellsMinimum.x, cellsMinimum.y));
	vec2 lowerRightDirection = random(vec2(cellsMaximum.x, cellsMinimum.y));
	vec2 upperLeftDirection = random(vec2(cellsMinimum.x, cellsMaximum.y));
	vec2 upperRightDirection = random(vec2(cellsMaximum.x, cellsMaximum.y));
	
	vec2 fraction = fract(uv);
	
	return mix( mix( dot( lowerLeftDirection, fraction - vec2(0, 0) ),
					 dot( lowerRightDirection, fraction - vec2(1, 0) ), blur.x),
				mix( dot( upperLeftDirection, fraction - vec2(0, 1) ),
					 dot( upperRightDirection, fraction - vec2(1, 1) ), blur.x), blur.y) * 0.8 + 0.5;
}

vec3 getColour(int id) {
	vec3 colours[3];
	
	colours[0] = vec3(50./255.,40./255.,35./255.); // Balatro black
	colours[1] = vec3(220./255.,80./255.,20./255.);
	colours[2] = vec3(240./255.,220./255.,180./255.);
	
	return colours[id];
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec2 coord = vec2((texture_coords.x-offset.b/offset.r)*offset.r,(texture_coords.y-offset.a/offset.g)*offset.g);

	vec2 uv = coord/size;
	vec4 col = Texel(texture,texture_coords);

	vec2 diff = size * 0.5 - abs(coord - size * 0.5);
	float dist = 1.-min(diff.x, diff.y)/10./(amp*0.2)+amp*0.3;
	
	float noise = seamless_noise(uv*size/300.,vec2(40.,0.));
	
	float burn = 1.-(noise-((dist+.5)/2.));
	
	burn = floor(burn*10.)/10.; // Banding effect for stylization
	
	vec3 burnc = mix(getColour(1),getColour(0),clamp(burn*1.7-.5,amp*.1,1.));
	
	col = clamp(vec4(col.xyz*mix(vec3(1.),getColour(2),amp/3.),col.a),0.,1.);
	
	col = dist>noise ? vec4(0.) : vec4(mix(col.xyz,burnc,clamp(burn*1.7,0.,1.)),col.a);

	return col;
}