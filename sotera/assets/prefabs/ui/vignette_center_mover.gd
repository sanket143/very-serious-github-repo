extends Node2D

# the colorrect that holds the vignette shader
@export var color_rect : ColorRect

# set this as the global position you want the vignette center to be at
var origin_point_global_position 

func _process(delta: float) -> void:
	
	
	var viewport := get_viewport()
	
	# this line is just for testing purposes, comment it out when not needed
	origin_point_global_position = get_global_mouse_position() # - viewport.get_visible_rect().size * 0.5
	
	var screen_pos: Vector2 = viewport.get_canvas_transform() * origin_point_global_position
	var center: Vector2 = screen_pos / viewport.get_visible_rect().size
	color_rect.material.set_shader_parameter("custom_center" , center)
