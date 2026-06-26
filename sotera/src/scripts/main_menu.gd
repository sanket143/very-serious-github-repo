extends Node

class_name MenuRoot

@export var target_scene: String

func _ready() -> void:
	MusicPlayer.play_track(MusicPlayer.MAIN_THEME, 0.1, 0.0, -9.0)

func _on_play_pressed() -> void:
	Events.change_level(target_scene)
	MusicPlayer.stop_track(2.0)

func _on_volume_slider_value_changed(value: float) -> void:
	# set master volume using scroll
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
