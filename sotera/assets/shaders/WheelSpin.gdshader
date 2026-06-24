shader_type canvas_item;

uniform float offset = 0.0;
uniform sampler2D spinnerTexture;

void fragment() {
	vec2 uv = UV.xy;

	// Hack to only show the part which is in the wheel
	if(uv.y < 0.04 || uv.y > 0.92){
		COLOR.a = 0.0;
	} else {
		uv.y = modf(uv.y + offset, uv.y);
		COLOR = texture(spinnerTexture, uv);
	}
}
