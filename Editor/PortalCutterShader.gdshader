shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;
stencil_mode write, compare_always, 1;

uniform mat4 cutplane;
uniform float enable_cut = 1;
uniform float cut_direction = 1;
varying vec3 wvtx;

void vertex() {
	wvtx = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 plane_normal = normalize(cut_direction * -cutplane[2].xyz);
	float plane_dist = dot(plane_normal, cutplane[3].xyz);
	float vertex_dist = dot(plane_normal, wvtx);
	float dist = max(vertex_dist - plane_dist, -enable_cut);
	
	if (dist < 0.0) discard;
	
	//ALPHA = 0.0;
}



//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
