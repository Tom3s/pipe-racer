shader_type spatial;
render_mode cull_disabled;

uniform vec3 color : source_color;
uniform vec2 noise_scale;
uniform vec2 noise_scale2;
uniform float cutoff;
//uniform float transparency;

#include "res://Visuals/utils.gdshaderinc"

void fragment() {
	float gradient = abs(UV.x - 0.5);
	gradient = smoothstep(0.35, 0.5, gradient);
	
	float side_noise = perlin_noise(UV * 10.0) * gradient;
	
	
	float noise = perlin_noise(UV * noise_scale);
	noise = clamp(remap(noise, .05, .4, 0., 1.), 0., 1.);
	
	float noise2 = perlin_noise(UV * noise_scale2);
	noise2 *= noise2 * noise2;
	noise2 *= 0.3;
	
	float mask = noise * (1.0 - side_noise);
	
	ALBEDO = noise2 * (color);
	dither_transparency(cutoff * mask, FRAGCOORD.xy);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
