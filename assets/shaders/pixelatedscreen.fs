extern sampler2D palette;
extern vec2 paletteSize;
extern vec2 dims;

float bayer4(vec2 pos) { 
	int x = int(mod(pos.x, 4.0));
	int y = int(mod(pos.y, 4.0));
	int index = y * 4 + x;
	
    float bayer[16];
    bayer[0] =  0.0; bayer[1] =  8.0; bayer[2] =  2.0; bayer[3] = 10.0;
    bayer[4] = 12.0; bayer[5] =  4.0; bayer[6] = 14.0; bayer[7] =  6.0;
    bayer[8] =  3.0; bayer[9] = 11.0; bayer[10] = 1.0; bayer[11] =  9.0;
    bayer[12] = 15.0; bayer[13] = 7.0; bayer[14] = 13.0; bayer[15] = 5.0;
	
	float threshold = bayer[index];
	return (threshold + 0.5) / 16.0;
}

float perceptualDist(vec3 a, vec3 b) {
    vec3 dif = a - b;
    return dot(dif * dif, vec3(0.299, 0.587, 0.114));
}

vec4 paletteFix(vec4 tex, vec2 uv, vec2 dims) {
	// The found colours' UV coordinates 
	vec2 target = vec2(0.0,0.0);
	vec2 target2 = vec2(0.0,0.0);
	
	// The found colours' distances from the original colour. Should not exceed ~1.44 normally.
	float targdist = 2.0;
	float targdist2 = 2.0;
	
	// Iterate through each pixel in the palette sprite (each colour)
	for (float i = 0.0; i < paletteSize.x*paletteSize.y; i++) {
		// Get the texture coordinates for the current palette colour with 0-1 range
		vec2 palCoord = vec2( mod( i, paletteSize.x ), floor( i / paletteSize.x ) ) / paletteSize;
		palCoord += vec2(.5,.5) / paletteSize; // Center UV coordinates on middle of pixels to prevent floating point imprecision
		
		// The palette colour being compared against
		vec3 comp = texture2D( palette, palCoord ).rgb;
		
		// Distance between the palette colour and the input colour
		float dist = perceptualDist(tex.rgb,comp);
		
		// I'm using ternary operators here because apparently if statements are more taxing on the GPU
		// Secondary colour is handled first to prevent weird logic shenanigans :p
		
		// Secondary colour
		target2 = dist < targdist ? target : (dist < targdist2 ? palCoord : target2);
		targdist2 = dist < targdist ? targdist : (dist < targdist2 ? dist : targdist2);
		
		// Main colour
		target = dist < targdist ? palCoord : target;
		targdist = dist < targdist ? dist : targdist;
	}
	
	float factor = targdist/(targdist + targdist2);
	
	vec2 cCoords = factor > bayer4(dims) ? target2 : target;
	
	return vec4(texture2D( palette, cCoords ).rgb,tex.a);	
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 tex = Texel(texture, floor(texture_coords*dims+.5)/dims);
	tex = paletteFix(tex,screen_coords,texture_coords*dims+.5);
	return tex;
}

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    return transform_projection * vertex_position;
}
#endif