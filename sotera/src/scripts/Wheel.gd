extends Node
class_name Wheel

enum WHEELSTATE{
	SPINNING,
	IDLE
}

#State of the wheel
var state:WHEELSTATE = WHEELSTATE.IDLE

#Array of whatever items the wheel is gonna pick from - String is used as placeholder
@export var items:Array[String]
@export var min_speed:float
@export var max_speed:float
@export var min_time:float
@export var max_time:float
#temp label for testing purposes
@export var label:Label
#current speed of the wheel in items/millisecond
var spin_speed:float = 0.0
var spin_time:float = 0.0
var elapsed_spin_time:float = 0.0
#multiplier of the speed gotten from tween
var speed_mult:float = 0.0
#current position in the list of items [0,list size]
var spin_pos:float = 0.0

func _input(event):
	if event.is_action_pressed("ui_accept"):
		start_spinning()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = items[spin_pos]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#FSM
	match state:
		WHEELSTATE.SPINNING:
			print(speed_mult)
			label.text = items[spin_pos]
			if elapsed_spin_time<spin_time:
				speed_mult = 1.0-lerp(0,1,TweenUtils.ease_out_quart(elapsed_spin_time/spin_time))
				spin_pos = fmod(spin_pos+spin_speed * delta * speed_mult,items.size())
				elapsed_spin_time+=delta
			else:
				stop_spinning()
				pass
		WHEELSTATE.IDLE:
			pass
	
#Call from the lever
func start_spinning()->void:
	if state == WHEELSTATE.IDLE:
		state = WHEELSTATE.SPINNING
		spin_speed = RandUtils.randf_range(min_speed,max_speed)
		spin_time = RandUtils.randf_range(min_time,max_time)
		elapsed_spin_time = 0

func stop_spinning()->void:
	#Check if wheel is spinning in case its called outside the FSM
	if state == WHEELSTATE.SPINNING:
		state = WHEELSTATE.IDLE
		var _result = items.get(int(spin_pos))
		#publish the result here
