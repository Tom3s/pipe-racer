shader_type spatial;
//render_mode depth_test_disabled;
//stencil_mode read, write, compare_equal, 1;

uniform vec3 color : source_color;

#include "res://Visuals/utils.gdshaderinc"

void fragment() {
	ALBEDO = color;
	
	dither_transparency(0.35, FRAGCOORD.xy);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
