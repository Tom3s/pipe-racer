const vec3 DITHER_MAGIC_NUM = vec3(0.06711056f, 0.00583715f, 52.9829189f);

void dither_transparency(float transparency, vec2 frag_coord) {
	if (transparency < 0.001 || transparency < fract(DITHER_MAGIC_NUM.z * fract(dot(frag_coord.xy, DITHER_MAGIC_NUM.xy)))) {
		discard;
	}
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = (v - inMin) / (inMax - inMin);
  return outMin + (outMax - outMin) * t;
}

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float perlin_noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

const int SEAMLESS_PERLIN_CELL_AMOUNT = 20;

vec2 modulo(vec2 divident, vec2 divisor){
	vec2 positiveDivident = mod(divident, divisor) + divisor;
	return mod(positiveDivident, divisor);
}

float seamless_noise(vec2 uv, vec2 _period) {
	uv = uv * float(SEAMLESS_PERLIN_CELL_AMOUNT);
	vec2 cellsMinimum = floor(uv);
	vec2 cellsMaximum = ceil(uv);
	vec2 uv_fract = fract(uv);
	
	cellsMinimum = modulo(cellsMinimum, _period);
	cellsMaximum = modulo(cellsMaximum, _period);
	
	vec2 blur = smoothstep(0.0, 1.0, uv_fract);
	
	vec2 lowerLeftDirection = random(vec2(cellsMinimum.x, cellsMinimum.y));
	vec2 lowerRightDirection = random(vec2(cellsMaximum.x, cellsMinimum.y));
	vec2 upperLeftDirection = random(vec2(cellsMinimum.x, cellsMaximum.y));
	vec2 upperRightDirection = random(vec2(cellsMaximum.x, cellsMaximum.y));
	
	vec2 fraction = fract(uv);
	
	return mix( mix( dot( lowerLeftDirection, fraction - vec2(0, 0) ),
                     dot( lowerRightDirection, fraction - vec2(1, 0) ), blur.x),
                mix( dot( upperLeftDirection, fraction - vec2(0, 1) ),
                     dot( upperRightDirection, fraction - vec2(1, 1) ), blur.x), blur.y) * 0.8 + 0.5;
}

float ease_in_out_cubic(float x) {
	return x < 0.5 ? 4.0 * x * x * x : 1. - pow(-2.0 * x + 2.0, 3.) * .5;
}

void dither_noise(float transparency, vec2 frag_coord) {
	if (transparency < 0.001 || transparency < random(frag_coord).x) {
		discard;
	}
}