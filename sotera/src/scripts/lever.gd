extends Node2D

#LeverStates
enum LeverState {
	IDLE,
	PULLING_DOWN,
	PULLING_UP
}
var current_state: LeverState = LeverState.IDLE


#RNG Timing Variables
@export var min_pull_time : float = 0.5
@export var max_pull_time : float = 2.5
@export var pull_up_time : float = 1.0

@onready var area : Area2D = $Area2D

var can_interact : bool = false

#Signal to cleanly notify fortune wheel
signal fortune_wheel_started

func _ready() -> void:
	#Clear junk values from the inspector for safety measures
	area.collision_layer = 0
	area.collision_mask = 0
	
	#Setting the collision layers and the mask using the collision config
	area.collision_layer = CollisionConfig.LEVER_SENSOR_COLLISION_PHYSIC_ID
	area.collision_mask = CollisionConfig.PLAYER_COLLISION_PHYSIC_ID
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
func _on_body_entered(body: Node2D) -> void:
		print("Player Entered")
		can_interact = true
		
func _on_body_exited(body:Node2D) -> void:
		can_interact = false
		print("Player Exited")
	
	

func on_start_pulling() -> void:
	if current_state == LeverState.IDLE:
		_start_pull_down()

func _start_pull_down() -> void:
	current_state = LeverState.PULLING_DOWN

	#generate the random duration for the pull time between x and y
	var pull_duration = randf_range(min_pull_time, max_pull_time)
	
	#create the tween to handle the timing
	var tween = create_tween()
	tween.tween_callback(_on_pulldown_finished).set_delay(pull_duration)
	
func _on_pulldown_finished() -> void:
	fortune_wheel_started.emit()
	
	#trigger the lever pull up
	
	_start_lever_auto_pull_up()
	
func _start_lever_auto_pull_up() -> void:
	current_state = LeverState.PULLING_UP
	
	var tween = create_tween()
	tween.tween_callback(_on_pulling_up_over).set_delay(pull_up_time)
	
func _on_pulling_up_over() -> void:
	current_state = LeverState.IDLE	
	
