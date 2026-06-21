shader_type canvas_item;

uniform float offset = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV.xy;
	uv.y = modf(uv.y + offset, uv.y);
	COLOR = texture(TEXTURE, uv);
	//COLOR.rgb = uv.yyy;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
