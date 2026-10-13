shader_type spatial;
render_mode unshaded, depth_test_inverted, depth_draw_never;
stencil_mode read, compare_not_equal, 3;

uniform float dither_treshold = 0.25;
uniform vec3 color : source_color;

#include "res://Visuals/utils.gdshaderinc"

void fragment() {
	dither_transparency(dither_treshold, FRAGCOORD.xy);
	
	ALBEDO.rgb = color;
	//EMISSION = vec3(.5);
}
