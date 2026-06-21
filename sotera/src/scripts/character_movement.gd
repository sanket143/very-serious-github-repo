extends CharacterBody2D

const SPEED = 300
#const JUMP_VELOCITY = -400

func _physics_process(delta: float) -> void:

	var direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	velocity = direction * SPEED

	move_and_slide()
