shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D viewport_texture : source_color;

#include "Visuals/utils.gdshaderinc"
#include "Visuals/uv_manipulation.gdshaderinc"

uniform vec2 noise_size = vec2(0.5, 1.6);
uniform vec2 vortex_speed1 = vec2(0.035, 0.0);
uniform vec2 noise_period = vec2(50.0, 16.0);
uniform float swirl_strength = 4.35;
uniform float portal_displace = 0.02;


void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = radial_uv(UV) * noise_size;
	uv.y += uv.x * swirl_strength;
	
	vec2 vertex_uv1 = uv;
	vertex_uv1 += TIME * vortex_speed1;
	
	float noise_pass1 = seamless_noise(vertex_uv1 * vec2(1., .25), noise_period * vec2(1., .25));

	
	vec2 distorted_uv = SCREEN_UV;
	distorted_uv += remap(noise_pass1, 0.0, 1.0, -portal_displace, portal_displace);
	//distorted_uv *= 0.25;
	//distorted_uv += 1.0;
	ALBEDO.rgb = texture(viewport_texture, distorted_uv).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
