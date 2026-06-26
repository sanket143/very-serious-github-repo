extends MainMenuBtn

class_name MainMenuCreditsBtn

@export var credits_scene: String

func _on_click() -> void:
	super._on_click()
	curtain_system.open_full()
	Events.change_level(credits_scene)
	SoundPool.play_random_sound(SoundPool.UI_CLICK)
