extends Node2D

# to block visual pause menu pop glitch
signal start_closing_curtains

enum WheelState {
	IDLE, # player is insdie Fortune Wheel Scene
	SPINNING, # goes to WAIT_CURTAINS_TO_CLOSE
	WAIT_CURTAINS_TO_CLOSE # goes back to IDLE & change scene to mini-game
}

var _state: WheelState = WheelState.IDLE;
var offset: float = 0.0;
var spin_speed: float = 0.0;
var spin_time: float = 0.0;
var min_speed: float = 0.1;
var max_speed: float = 0.2;
var min_time: float = 3.0;
var max_time: float = 5.0;

var speed_multiplier: float = 0.0;

enum MiniGame { 
	MAZE = 0,
	BULLET = 1,
	SCARY = 2,
	QUIZ = 3,
	# STORY = 4 not yet implemented
}

var mini_game_name_map: Dictionary[MiniGame, String] = {
	MiniGame.MAZE: "maze",
	MiniGame.BULLET: "bullet",
	MiniGame.SCARY: "scary",
	MiniGame.QUIZ: "quiz",
	# MiniGame.STORY: "story" not yet implemented
}

var mini_game_map: Dictionary[MiniGame, String] = {
	MiniGame.MAZE: "res://assets/scenes/StandardMaze.tscn",
	MiniGame.BULLET: "res://assets/scenes/BulletHellMinigame.tscn",
	MiniGame.SCARY: "res://assets/scenes/ScaryMaze.tscn",
	MiniGame.QUIZ: "res://assets/scenes/FinalBoss.tscn",
	# MiniGame.STORY: "res://assets/scenes/ScaryMaze.tscn" not yet implemented
}

var elapsed_spin_time: float = 0.0;
var single_value_height_in_texture: float = 1.0 / mini_game_map.size();
var value_idx: int = 2;

@export var curtains: CurtainSystem
@export var minigame_tracker: MiniGameTracker

@onready var effect1: Node2D = $WheelSpinEffect
@onready var effect2: Node2D = $WheelSpinEffect2
@onready var wheel_material: Material = $WheelTexture.material
@onready var wheel_value: Label = $WheelValue

func _ready() -> void:
	offset = Events.get_spinner_start_offset()

func _physics_process(delta: float) -> void:
	match _state:
		WheelState.IDLE: return
		WheelState.WAIT_CURTAINS_TO_CLOSE: check_if_curtains_are_closed()
		WheelState.SPINNING: update_spin(delta)


func update_spin(delta: float) -> void:
	if elapsed_spin_time < spin_time:
		speed_multiplier = 1.0 - lerp(
			0,
			1,
			TweenUtils.ease_out_quart(elapsed_spin_time / spin_time)
		);

		elapsed_spin_time += delta

		offset += speed_multiplier;
		offset = fmod(offset, 1.0);
		if(spin_time - elapsed_spin_time < (spin_time * 0.25)):
			if(effect1.state != effect1.WheelPEState.SPEED_DOWN_TRANSITION): effect1.stop_pe_impact()
			if(effect2.state != effect2.WheelPEState.SPEED_DOWN_TRANSITION): effect2.stop_pe_impact()
			
	else: _stop()
	
	var n: int = mini_game_map.size()
	value_idx = (int((offset + 0.1) / single_value_height_in_texture) + floori(n / 2)) % n;

	wheel_material.set_shader_parameter("offset", offset);
	wheel_value.text = mini_game_name_map[value_idx]

func start_spinning() -> void:
	if _state != WheelState.IDLE: return # IDLE -> SPINNING
	
	_state = WheelState.SPINNING
	spin_speed = min_speed # RandUtils.randf_range(min_speed, max_speed)
	spin_time = min_time # RandUtils.randf_range(min_time, max_time)
	elapsed_spin_time = 0

	SoundPool.play_sound(SoundPool.WHEEL_START)

	effect1.start_speedup()
	effect2.start_speedup()
	
	await get_tree().create_timer(spin_time * 0.45).timeout
	
	SoundPool.play_sound(SoundPool.WHEEL_STOP)

func check_if_curtains_are_closed() -> void:
	if !curtains.closed(): return
	
	SoundPool.play_sound(SoundPool.MINIGAME_SELECTED)
	Events.change_level(mini_game_map[value_idx])
	
	_state = WheelState.IDLE
	
func _stop() -> void:
	if minigame_tracker:
		var winning_game: String = mini_game_name_map[value_idx]
		minigame_tracker.add_minigame(winning_game)
		
	_start_closing_curtains()	


		
func _start_closing_curtains() -> void:
	# PROCEDURE:
	# 1 ... start closing curtains
	# 2 ... curtains == closed -> start_mini_game()
	
	_state = WheelState.WAIT_CURTAINS_TO_CLOSE
	
	Events.increase_spinner_starting_positoin()
	effect1.start_slowdown()
	effect2.start_slowdown()
	curtains.close_full()
	
	start_closing_curtains.emit()
	
	SoundPool.stop_sound(SoundPool.AUDIENCE_CHEER, 5.0)

func _on_lever_lever_pulled() -> void:
	start_spinning()
	SoundPool.play_sound(SoundPool.LEVER_PULL)
	SoundPool.play_sound(SoundPool.AUDIENCE_CHEER)
