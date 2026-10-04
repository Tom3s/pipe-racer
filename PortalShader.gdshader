shader_type spatial;
render_mode unshaded, cull_front;
uniform sampler2D viewport_texture : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO.rgb = texture(viewport_texture, SCREEN_UV).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
