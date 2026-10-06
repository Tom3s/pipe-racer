shader_type spatial;
render_mode depth_test_disabled;
stencil_mode read, compare_equal, 1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(1.0, 0.0, 0.0);
	//ALPHA = 0.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
