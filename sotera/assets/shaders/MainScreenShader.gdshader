shader_type canvas_item;

const vec2 CENTER = vec2(0.5);
uniform sampler2D screen_texture : hint_screen_texture;
uniform vec2 custom_center; //change this with the vignette_center_mover script if needed

group_uniforms VignetteSettings;
uniform sampler2D vignette_gradient;
uniform float circle_or_ellipse : hint_range(0.0,1.0,1.0) = 0.0;
uniform float vignette_strength : hint_range(0.0,10.0) = 0.5;
uniform float vignette_spread : hint_range(1.0,5.0) = 1.0;

group_uniforms CrtSettings;
uniform float warp_intensity;
uniform vec4 scanline_color : source_color;
uniform float scanline_amount;
uniform float scanline_movement;
uniform float scanline_opacity : hint_range(0.0, 1.0);
uniform float scanline_thickness : hint_range(0.0, 1.0);


group_uniforms VhsSettings;
uniform sampler2D static_noise : repeat_enable; //add a noise texture here
uniform float static_opacity : hint_range(0.0, 1.0);
uniform vec4 static_color : source_color;
uniform float vhs_threshold : hint_range(0.0, 1.0);
uniform float vhs_change_speed;
uniform float vhs_scroll_speed;
uniform float vhs_strength : hint_range(0.0, 1.0);
uniform float vhs_distortion;

void fragment() {
	
	//warped_uv
	vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
	vec2 uv_offset = 1.0 + centered_uv.yx / warp_intensity * centered_uv.yx / warp_intensity;
	vec2 mask_uv = centered_uv * uv_offset;
	float warp_mask =
	step(abs(mask_uv.x), 1.0) *
	step(abs(mask_uv.y), 1.0);
	vec2 warped_uv = (mask_uv + 1.0) / 2.0;
	
	//scaledUV
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaledUV = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	
	//vignette UV shape 
	vec2 circle_or_ellipse_uv = scaledUV * circle_or_ellipse + warped_uv * (1.0-circle_or_ellipse);
	vec2 scaledCustomCenter = (custom_center - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	vec2 circle_or_ellipse_center =  scaledCustomCenter * circle_or_ellipse + CENTER * (1.0-circle_or_ellipse);
	
	vec4 vignette_mask = texture(vignette_gradient, vec2(
	pow(min(1.0,distance(circle_or_ellipse_uv , circle_or_ellipse_center)) * vignette_strength, vignette_spread),
	 0.5));
	
	//scanlines
	vec4 scanline_mask = (scanline_color 
	* step( 1.0 - scanline_thickness * 2.0,
	sin(warped_uv.y * 50.0 * scanline_amount + TIME * 10.0 * scanline_movement) ))
	* warp_mask * scanline_opacity ;
	
	//static noise
	float random = fract(sin(dot(warped_uv, vec2(12.9898, 78.233) * TIME)) * 438.5453) * 1.9;
	float vhs_texture = 
	texture(static_noise,
	vec2(warped_uv.y + TIME * vhs_scroll_speed, TIME * vhs_change_speed) ).r;
	float vhs_mask =  min(vhs_texture,
	step(vhs_threshold, vhs_texture ));
	vec4 static_overlay = static_color * random * warp_mask
	* (static_opacity + vhs_mask * vhs_strength) ;
	
	
	//final color
	vec4 screen_color = texture(screen_texture, warped_uv + vec2(vhs_mask * 0.005 * vhs_distortion,0.0));
	COLOR = screen_color * vignette_mask 
	* vec4(vec3(warp_mask), 1.0) + scanline_mask + static_overlay;
}