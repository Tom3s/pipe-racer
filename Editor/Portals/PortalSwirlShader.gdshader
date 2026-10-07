shader_type spatial;
render_mode cull_disabled;

uniform vec3 swirl_color : source_color;
uniform vec2 side_dist;
uniform float swirl_strength;
uniform vec2 noise_size;
uniform vec2 noise_period = vec2(5., 10.);
uniform float spin_speed = .2;
uniform vec2 vortex_speed1 = vec2(.3);
uniform vec2 vortex_speed2 = vec2(.3);




#include "res://Visuals/uv_manipulation.gdshaderinc"
#include "res://Visuals/utils.gdshaderinc"

void fragment() {
	//ALBEDO = swirl_color;
	//EMISSION = swirl_color;
	vec2 uv = radial_uv(UV) * noise_size;
	uv.y += uv.x * swirl_strength;
	//dither_transparency(uv.x, FRAGCOORD.xy);
	vec2 abs_uv = abs(UV - .5);
	float dist_from_side = max(abs_uv.x, abs_uv.y);
	float side_mask = remap(dist_from_side, side_dist.x, side_dist.y, 0., 1.);
	side_mask = clamp(side_mask, 0., 1.);
	side_mask = pow(side_mask, 8);
	side_mask *= .5;
	
	//uv.x += TIME * vortex_speed;
	vec2 vertex_uv1 = uv;
	vertex_uv1 += TIME * vortex_speed1;
	vec2 vertex_uv2 = uv;
	vertex_uv2 += TIME * vortex_speed2;
	
	float noise_pass1 = seamless_noise(vertex_uv1 * vec2(1., .25), noise_period * vec2(1., .25));
	float noise_pass2 = seamless_noise(vertex_uv2, noise_period);
	//noise_pass2 = remap(noise_pass2, .4, .0, 0., 1.);
	noise_pass1 *= .7;
	noise_pass2 *= .4;
	//noise_pass2 = step(.2, noise_pass2);
	
	float vertex_effect = (noise_pass1 + noise_pass2 + side_mask);
	//vertex_effect = step(.6, vertex_effect);
	vertex_effect = smoothstep(0.55, 0.7, vertex_effect);
	
	float swirl_overlay = vertex_effect * ease_in_out_cubic(dist_from_side * 2.);
	
	dither_transparency(swirl_overlay, FRAGCOORD.xy);
	//ALPHA = swirl_overlay;
	//ALBEDO = vec3(step(.7, UV.x));
	ALBEDO = swirl_color;
	EMISSION = swirl_color * noise_pass2 * 1.42857142857;
}
