extends Node

signal game_over

@export var curtains: CurtainSystem
@onready var dialogue: Dialogue = $"CanvasLayer/Dialogue"

# ------------------ jumpscare params --------------------
@export var jumpscare: JumpScareController
@export var range_max_delay: Vector2 = Vector2(1.82, 2.4)
@onready var crt: CrtControl = $CanvasLayer/CRT
@onready var steve: Node = $World/FG/Steven
@onready var wheel: Node = $World/FG/Wheel
@onready var lever: Node = $World/FG/Lever
@onready var gui: Node = $CanvasLayer/GUI
var time: float
var max_time: float

@export var range_hand_rise: Vector2 = Vector2(3.5, 4.8)
@export var menu_game_over_mode: String
# ------------------ jumpscare params --------------------

enum GameState{
	NORMAL, # normal state
	GAME_OVER_FLICK_DELAY, GAME_OVER_HAND_UP, # only happens at game over: GAME_OVER_FLICK_DELAY -> GAME_OVER_HAND_UP
	GAME_OVER_CURTAINS_CLOSE, GAME_OVER
}

var _game_state: GameState = GameState.NORMAL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curtains.open_full()
	MusicPlayer.play_track(MusicPlayer.STAGE_MUSIC, 0.1, 0.0, -7.5)
	dialogue.start_next_dialog()
	dialogue.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Globals.Total_contracts > 0:
		SoundPool.play_sound(SoundPool.AUDIENCE_CHEER)
		
func _process(delta: float) -> void:
	match _game_state:
		GameState.NORMAL: pass
		GameState.GAME_OVER_FLICK_DELAY: flick_update(delta)
		GameState.GAME_OVER_HAND_UP: update_game_over_hand_up(delta)
		GameState.GAME_OVER_CURTAINS_CLOSE: check_curtains_closed()

func check_curtains_closed() -> void:
	if !curtains.closed(): return
	
	Events.change_level(menu_game_over_mode)
	_game_state = GameState.GAME_OVER
	
	
func _exit_tree() -> void:
	MusicPlayer.stop_track(2.0)


func update_game_over_hand_up(delta: float) -> void:
	time = min(time + delta, max_time)
	if time == max_time: start_curtain_close()

func start_curtain_close() -> void:
	curtains.close_full()
	curtains.lock()
	_game_state = GameState.GAME_OVER_CURTAINS_CLOSE
	
# flicker specified target elements
func flick_update(delta: float) -> void:
	time = min(time + delta, max_time)
	if time == max_time: go_rise_hand()
	
func go_rise_hand() -> void:
	max_time = randf_range(range_hand_rise.x, range_hand_rise.y)
	time = 0.0
	
	jumpscare.start_hand_rise()
	_game_state = GameState.GAME_OVER_HAND_UP
	
	
	
func start_game_over() -> void:
	if _game_state != GameState.NORMAL: return # safe check
	
	max_time = randf_range(range_max_delay.x, range_max_delay.y)
	time = 0.0
	
	dialogue.on_stop_dialogue()
	crt.dark_flick(max_time)
	steve.visible = false
	wheel.visible = false
	lever.visible = false
	gui.visible = false
	game_over.emit()
	
	MusicPlayer.play_track(MusicPlayer.GAME_OVER)
	
	_game_state = GameState.GAME_OVER_FLICK_DELAY
	
	
func _input(e: InputEvent) -> void:
	if e is InputEventKey and !e.pressed and e.keycode == KEY_M:
		start_game_over()

func _on_dialogue_speech_ended() -> void:
	dialogue.hide()
	print("speech ended")
	print(Globals.Total_contracts)
	if Globals.Total_contracts == 3:
		print("lets change to final boss")
		Events.change_level("res://assets/scenes/FinalBoss.tscn")

