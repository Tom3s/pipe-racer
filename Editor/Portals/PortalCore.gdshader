shader_type spatial;

render_mode shadows_disabled;

uniform float anim_speed = 0.3;
uniform float anim_speed2 = 0.4;
uniform vec3 core_color : source_color;


#include "res://Visuals/utils.gdshaderinc"

void vertex() {
	COLOR.xyz = VERTEX;
}

void fragment() {
	//vec2 centered_uv = UV - vec2(0.5, 0.0);
	//centered_uv.x = abs(centered_uv.x);
	vec3 uv_3d = COLOR.xyz;
	uv_3d.z = abs(uv_3d.z);
	
	float pre_ease_uv = uv_3d.z;
	uv_3d.z = ease_in_cubic(uv_3d.z * 2.0);
	
	//ease_uv += TIME * anim_speed;
	uv_3d.z += TIME * anim_speed;
	pre_ease_uv += TIME * anim_speed2;
	
	pre_ease_uv += perlin_noise(vec2(pre_ease_uv, COLOR.y) * 5.0) * 0.1;
	pre_ease_uv += sin(COLOR.y) * 0.3;
	
	float voronoi = voronoi3d(uv_3d * 2.0).y;
	voronoi = ease_out_cubic(voronoi);
	voronoi = remap(voronoi, 0., 1., 1.0, 0.4);
	
	float sine_in = sin(pre_ease_uv * 10.0);
	float soft_sine_in = remap(sine_in, -1., 1., 0.4, 1.0);
	float positive_sine = (sine_in + 1.0) * .5;
	
	float first_noise = perlin_noise(COLOR.zy * 10.0);
	float final_noise = voronoi * soft_sine_in;
	float seam = abs(COLOR.z + (perlin_noise(UV * 10.0) - .5) * 0.1);
	seam = remap(seam, 0.0, 0.25, 1., 0.);
	seam = clamp(seam, 0., 1.);
	seam += (perlin_noise(UV * 5.0) - .5) * 0.1;
	EMISSION = core_color * positive_sine + core_color * seam;
	//dither_transparency(EMISSION.b, FRAGCOORD.xy);
	//ALBEDO = core_color * final_noise;
	ALBEDO = core_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
