shader_type spatial;

uniform vec3 base_color : source_color;
uniform vec3 rust_color : source_color;
uniform vec3 noise_scale = vec3(1.0);
uniform vec3 noise_dir = vec3(1.0);

uniform float rust_size = 0.1;
uniform float rust_strength = 1.0;

uniform float normal_bump = 0.03;
uniform vec2 roughness;

#include "res://Visuals/utils.gdshaderinc"

void vertex() {
	COLOR.xyz = VERTEX + NODE_POSITION_WORLD;
}

void fragment() {
	//vec3 squashed_uv = COLOR.xyz * noise_scale * noise_dir;
	mat3 noise_rot_mat = look_at(vec3(0.), normalize(noise_dir), vec3(0., 1., 0.));
	float surface_streaks = seamless_noise_3d(COLOR.rgb * noise_rot_mat * noise_scale);
	
	float noise_layer1 = seamless_noise_3d(COLOR.rgb * 2.0 * (1./rust_size));
	noise_layer1 = smoothstep(0.4, 1.0, noise_layer1);
	float noise_layer2 = seamless_noise_3d(COLOR.rgb * 5.0 * (1./rust_size)) * .5;
	float noise_layer3 = seamless_noise_3d(COLOR.rgb * 50.0);
	noise_layer3 = remap(noise_layer3, 0., 1., 0.15, .25);
	//float fractal_nosie = (noise_layer1 + noise_layer2 + noise_layer3) / 1.75;
	float fractal_noise = noise_layer1 * noise_layer2 * noise_layer3 * 8.0 * rust_strength;
	
	//float squashed_noise = ;
	//ALBEDO = base_color;
	ALBEDO = mix(base_color, rust_color, smoothstep(0., 0.4, fractal_noise));
	METALLIC = mix(0.9, 0.2, ease_out_cubic(fractal_noise));
	NORMAL = mix(NORMAL + remap(surface_streaks, 0., 1., -normal_bump, normal_bump), NORMAL, fractal_noise);
	ROUGHNESS = mix(remap(surface_streaks, 0., 1., roughness.x, roughness.y), 1., ease_out_cubic(fractal_noise));
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
