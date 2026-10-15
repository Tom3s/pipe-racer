shader_type spatial;
render_mode cull_disabled;

uniform vec3 color : source_color;
uniform float transparency;

#include "utils.gdshaderinc"

void fragment() {
	ALBEDO = color;
	dither_transparency(transparency, FRAGCOORD.xy);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
