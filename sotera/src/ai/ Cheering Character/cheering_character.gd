extends Node2D


enum States{SIT_IDLE, MOVING_TO_TARGE_SIT, MOVING_OUT, CHEERING}

@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export_range(1, 3) var fun_level: int
@export var min_wait_time: int = 5
@export var max_wait_time: int = 10 

var active_state: States

func _ready() -> void:
	active_state = States.SIT_IDLE
	on_start_sit_idle()

func _process(_delta: float) -> void:
	match active_state:
		States.SIT_IDLE:
			pass
		States.MOVING_TO_TARGE_SIT:
			pass
		States.MOVING_OUT:
			pass
		States.CHEERING:
			cheering()


func on_start_sit_idle():
	timer.wait_time = randi_range(min_wait_time, max_wait_time)
	active_state = States.SIT_IDLE
	timer.start()

func on_start_cheering() -> void:
	timer.wait_time = randi_range(min_wait_time, max_wait_time)
	timer.start()
	active_state = States.CHEERING

func cheering() -> void:
	pass

func move_to_next_sit() -> void:
	active_state = States.MOVING_TO_TARGE_SIT

func move_out() -> void:
	active_state = States.MOVING_OUT

func on_move_to_target_sit() -> void:
	pass

func _on_timer_timeout() -> void:
	timer.stop()
	match active_state:
		States.SIT_IDLE:
			on_sit_end()
		States.MOVING_TO_TARGE_SIT:
			pass
		States.MOVING_OUT:
			pass
		States.CHEERING:
			on_cheering_end()

func on_cheering_end() -> void:
	var rnd_num: float = randf()
	var chance_to_cheer_again: float

	match fun_level:
		1: chance_to_cheer_again = 0.20
		2: chance_to_cheer_again = 0.40
		3: chance_to_cheer_again = 0.70

	if rnd_num <= chance_to_cheer_again:
		on_start_cheering()
	else:
		var remaining_roll: int = randi_range(1, 3)
		match remaining_roll:
				1:
					on_start_sit_idle()
					print("on_start_sit_idle")
				2:
					move_to_next_sit()
					print("move_to_next_sit")

				3:
					move_out()
					print("move_out")


func on_sit_end():
	var rnd_num: int = randi_range(1, 4)
	print("cheering "+ str(rnd_num))
	match rnd_num:
			1:
				on_start_sit_idle()
				print("on_start_sit_idle")
			2:
				move_to_next_sit()
				print("move_to_next_sit")

			3:
				move_out()
				print("move_out")

			4:
				on_start_cheering()
				print("on_start_cheering")
