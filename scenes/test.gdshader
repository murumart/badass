shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = vec4(1, sin(TIME) * 0.5 + 0.5, UV.y, 1);
	if (distance(UV, vec2(0.5)) > 0.5) discard;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
