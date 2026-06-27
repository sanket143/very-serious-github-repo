extends Node

@export var curtains: CurtainSystem
@onready var dialogue: Dialogue = $"CanvasLayer/Dialogue"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curtains.open_full()
	MusicPlayer.play_track(MusicPlayer.STAGE_MUSIC, 0.1, 0.0, -7.5)
	dialogue.start_next_dialog()
	dialogue.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Globals.Total_contracts > 0:
		SoundPool.play_sound(SoundPool.AUDIENCE_CHEER)

func _exit_tree() -> void:
	MusicPlayer.stop_track(2.0)

func _on_dialogue_speech_ended() -> void:
	dialogue.hide()
	print("speech ended")
	print(Globals.Total_contracts)
	if Globals.Total_contracts == 3:
		print("lets change to final boss")
		Events.change_level("res://assets/scenes/FinalBoss.tscn")
