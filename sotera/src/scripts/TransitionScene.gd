extends Control

# This scene is an autoload you can access by typing 'TransitionScene'

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func transition_to(scene_path: String, speed_scale: float = 1):
	# Set animation speed
	animation_player.speed_scale = speed_scale
	
	# Fade to black
	animation_player.play("fade_to_black")
	
	# Wait until screen is black
	await animation_player.animation_finished
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)
	
	# Fade back in once scene is changed
	animation_player.play_backwards("fade_to_black")
