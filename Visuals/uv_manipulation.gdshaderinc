vec2 radial_uv(vec2 uv, float offset) {
	vec2 centered = uv - offset;

	// Radial (polar) coordinates
	float radius = length(centered);          // Distance from center [0.0 to ~0.707]
	float angle = atan(centered.y, centered.x); // Angle in radians [-PI to PI]

	// Normalize angle to [0.0, 1.0] if needed for texture sampling
	float normalizedAngle = (angle + PI) / (2.0 * PI);

	//vec2 radialUV = vec2(radius, normalizedAngle);
	
	return vec2(radius, normalizedAngle);
}

vec2 radial_uv(vec2 uv) {
	return radial_uv(uv, 0.5);
}