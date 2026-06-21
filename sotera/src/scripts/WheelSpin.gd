extends Node2D

var offset: float = 0.0;

# Ideally we'll export those variables
var spin_speed: float = 0.1;
var values: Array[int] = [
	5, 10, 15, 20, 25, 30
]

func _process(delta: float) -> void:
	offset += spin_speed;
	offset = (int(offset * 1000000) % 1000000) / 1000000.0;
	var single_value_height_in_texture = 1.0 / values.size();
	var value_idx = (int(offset / single_value_height_in_texture) + 3) % values.size();
	
	$WheelTexture.material.set_shader_parameter("offset", offset);
	$WheelTexture.material.set_shader_parameter("number_of_values", values.size());
	$WheelTexture.material.set_shader_parameter("current_value", value_idx);

	$WheelValue.text = str(values[value_idx])
	
	# TODO: Stop the spin after a while
	pass
