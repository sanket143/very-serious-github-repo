extends Node2D

@onready var ui_text = $"UiText"
@onready var curtain_system = $"Curtains"

@export var target_scene: String

func _ready() -> void:
	curtain_system.open_full()
	var dialogs = load("res://assets/narrative/dialogue/Scene_intro.tres")
	ui_text.on_start_dialogue(dialogs, 100)

func _on_ui_text_speech_ended() -> void:
	curtain_system.close_full()
	Events.change_level(target_scene)
