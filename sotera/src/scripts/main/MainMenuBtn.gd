extends ColorRect

class_name MainMenuBtn

enum MainMenuBtnState { GAIN_FOCUS, LOSE_FOCUS, NONE }
var state: MainMenuBtnState = MainMenuBtnState.NONE
var time: float

@export var min_scale: float = 1.0
@export var max_scale: float = 1.1
@export var max_time: float = 0.5
@export var crt: CrtControl
@export var pointer: PointerText # 2 arrows which points to the text (extra focus)

# --------------- Used to move curtaints a little on hover ---------------------
@export var curtain_system: CurtainSystem
@export var jump_scare: JumpScareController
# --------------- Used to move curtaints a little on hover ---------------------

var pressed: bool = false # self tracking state

var motion: CameraMotion = CameraMotion.new()
var base_offset: Vector2
var _target_color: Color

func _init_motion() -> void:
	base_offset = position
	motion.enable_scale = false
	motion.enable_offset = true
	motion.enable_rotation = false

func _ready():
	_init_motion()
	
	mouse_entered.connect(_on_hover_enter)
	mouse_exited.connect(_on_hover_exit)
	
	scale.x = min_scale
	scale.y = min_scale
	
	_target_color = $btn.get_theme_color("font_color")
	
	
func _process(delta: float) -> void:
	var dict: Dictionary = motion.get_motion(delta)
	position = base_offset + dict["offset"]
	
	if state == MainMenuBtnState.NONE: return
	
	match state:
		MainMenuBtnState.GAIN_FOCUS:
			time = min(time + delta, max_time)
			if time == max_time: state = MainMenuBtnState.NONE
		MainMenuBtnState.LOSE_FOCUS:
			time = max(time - delta, 0.0)
			if time == 0.0: state = MainMenuBtnState.NONE
	
	
	var t: float = time / max_time
	var calc_scale: float = lerp(min_scale, max_scale, t)
	
	scale.x = calc_scale
	scale.y = calc_scale

func _on_hover_enter():
	var uv_mouse_pos = ScreenUtils.uv_mouse_position(
		get_viewport().get_mouse_position(),
		get_viewport().get_visible_rect().size
	)

	# all triggered aniamtions -> player visaul feedback
	crt.start_darken(uv_mouse_pos)
	curtain_system.open_both_certains_a_little()
	pointer.point(self, _target_color)
	# all triggered aniamtions -> player visaul feedback
	
	state = MainMenuBtnState.GAIN_FOCUS
	time = 0.0
	
	SoundPool.play_random_sound(SoundPool.UI_SELECT)

func _on_hover_exit():
	# all triggered aniamtions -> player visaul feedback
	crt.stop_darken()
	curtain_system.close_both_certains_a_little()
	pointer.hide_pointers()
	# all triggered aniamtions -> player visaul feedback
	
	state = MainMenuBtnState.LOSE_FOCUS
	time = max_time
	
func _is_curtain_on_origin() -> bool:
	return state == MainMenuBtnState.NONE
	
func _gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_process_input(event.pressed)
	elif event is InputEventScreenTouch:
		_process_input(event.pressed)
		
				
func _process_input(is_pressed: bool) -> void:
	if is_pressed: pressed = true
	elif pressed:
		pressed = false
		_on_click()
		
func _on_click() -> void:
	SoundPool.play_random_sound(SoundPool.UI_CLICK)
