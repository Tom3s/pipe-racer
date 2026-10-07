shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D viewport_texture : source_color;

#include "Visuals/utils.gdshaderinc"

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 distorted_uv = SCREEN_UV;
	distorted_uv += remap(perlin_noise(UV * 10.0), 0.0, 1.0, -.01, .01);
	//distorted_uv *= 0.25;
	//distorted_uv += 1.0;
	ALBEDO.rgb = texture(viewport_texture, distorted_uv).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
