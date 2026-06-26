extends CharacterBody2D


@export var speed: int = 500

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dust: Node2D = $Dust


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if direction:
		velocity = direction * speed
		animated_sprite_2d.play("Walk")
		animated_sprite_2d.flip_h = direction.x < 0
		dust._on_player_start_moving()
	
	else:
		dust._on_player_stop_moving()
		velocity = Vector2.ZERO
		animated_sprite_2d.play("Idle")

	move_and_slide()

func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.animation == "Walk":
		if animated_sprite_2d.frame in [0, 4]:
			SoundPool.play_random_shuffled_sound(SoundPool.PLAYER_FOOTSTEPS)
