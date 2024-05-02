shader_type spatial;


global uniform sampler2D rishiri_heightmap;
global uniform sampler2D ground_heightmap;
global uniform sampler2D radius;
global uniform sampler2D rishiri_normalmap;
global uniform float rishiri_amplitude;
global uniform float ground_amplitude;


varying vec2 texture_position;
varying float height;

void vertex() {
	vec3 world_vertex = VERTEX + MODEL_MATRIX[3].xyz;
	texture_position = (world_vertex.xz + 0.5) / float(textureSize(rishiri_heightmap, 0).x);
	float amplitude = rishiri_amplitude;
	height = texture(rishiri_heightmap, texture_position).r;
	if(height < 0.01) {
		amplitude = ground_amplitude;
		height = texture(ground_heightmap, texture_position).r * texture(radius, texture_position).r;
	}
	VERTEX.y = height * amplitude;
}

void fragment() {
	NORMAL_MAP = texture(rishiri_normalmap, texture_position).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
