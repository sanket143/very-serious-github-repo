extends Node2D

@export var point_light: PointLight2D
@export var darkness: CanvasModulate
@export var player: CharacterBody2D

@onready var hp = 3

@onready var jumpscare: JumpScareController = $Jumpscare
@onready var static_anim: AnimationPlayer = $StaticAnim
@onready var player_starting_pos: Marker2D = $PlayerStartingPos
@onready var timer: Timer = $Timer
@onready var static_screen: TextureRect = $Static

var jumpscare_active: bool = false

#func _on_wall_area_body_entered(body: Node2D) -> void:
	## Player takes damage from walls
	#hp -= 1
	#if hp == 0:
		## Change to game over scene
		#get_tree().change_scene_to_file("res://assets/scenes/FortuneWheelScene.tscn")

func _on_exit_area_body_entered(body: CharacterBody2D) -> void:
	if jumpscare_active:
		return
		
	jumpscare_active = true
	
	# Disable player and exit area
	player.visible = false
	player.get_node("Footsteps").stop()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Disable darkness and trigger jumpscare
	point_light.visible = false
	darkness.visible = false
	
	jumpscare.start_jumpscare()
	
	# Wait till jumpscare is done
	await jumpscare.jumpscare_finished
	jumpscare.voice.stop()
	
	# Static
	static_screen.global_position = player.global_position * static_screen.pivot_offset_ratio
	static_anim.play("play_static")
	await static_anim.animation_finished
	
	# Reset player state and level
	player.visible = true
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.global_position = player_starting_pos.global_position
	
	point_light.show()
	darkness.show()
	static_anim.play("RESET")
	timer.start()

func _on_timer_timeout() -> void:
	jumpscare_active = false
