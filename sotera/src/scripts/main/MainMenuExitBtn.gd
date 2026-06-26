extends MainMenuBtn

class_name MainMenuExitBtn

@onready var crossed_texture: TextureRect = $"Exit Blocker"
var do_jumpscare_on_first_click: bool = true

func _on_click() -> void:
	super._on_click()
	
	if do_jumpscare_on_first_click: _on_first_click()
	else: _on_2nd_click()
	
	curtain_system.open_full()

func _on_2nd_click() -> void:
	get_tree().quit()
	
func _on_first_click() -> void:
	do_jumpscare_on_first_click = false
	crossed_texture.visible = false
	jump_scare.start_jumpscare()
	MusicPlayer.stop_track(1.0)
