shader_type spatial;


global uniform sampler2D heightmap;
global uniform float amplitude;

varying vec2 texture_position;
varying float height;

void vertex() {
	vec3 world_vertex = VERTEX + MODEL_MATRIX[3].xyz;
	texture_position = (world_vertex.xz + 0.5) / float(textureSize(heightmap, 0).x);
	height = texture(heightmap, texture_position).r;
	VERTEX.y = height * amplitude;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
