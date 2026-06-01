extern vec2 dims;
extern vec2 pos;

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 tex = Texel(texture, texture_coords);
	float dist = distance(texture_coords*dims,pos);
	tex = dist<100. ? tex : tex*0.75; // Uses mix instead of ternary to achieve antialiasing
	return tex;
}

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    return transform_projection * vertex_position;
}
#endif