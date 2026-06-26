extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicPlayer.play_track(MusicPlayer.MINIGAME, 1.5, 0.0, -2.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _exit_tree() -> void:
	MusicPlayer.stop_track(2.0)
