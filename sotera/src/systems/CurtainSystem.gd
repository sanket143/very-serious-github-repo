extends ParallaxLayerA

class_name CurtainSystem

signal on_close
signal on_opening

enum CurtainSystemState { 
	CLOSED,
	OPENING_A_LITTLE, OPEN_A_LITTLE, CLOSING_A_LITTLE,
	
	# Used for: Open game -> exit -> jumpscare proced 1x -> forced into game, 2nd exit you are able to quet game
	# Used for scene transition main -> game (maybe other too)
	OPENING_FULL, OPEN_FULL, CLOSING_FULL
}

@export var curtain_left: CurtainController
@export var curtain_right: CurtainController


var origin_left: Vector2
var origin_right: Vector2

var _state: CurtainSystemState = CurtainSystemState.CLOSED
var time: float
var max_time: float

var locked: bool = false # visible, upfdates but action disabled



# --------------------------------- little open params ----------------------------------
@export var range_side_offset_x: Vector2 = Vector2(10.0, 20.0)
@export var range_side_offset_y: Vector2 = Vector2(0.0, 4.0)
@export var range_max_open_close_time: Vector2 = Vector2(3.2, 5.6)
var little_open_offset: Vector2
# --------------------------------- little open params ----------------------------------


# ---------------------------- full open params ----------------------------------------
@export var range_side_full_offset_x: Vector2 = Vector2(750.0, 820.0)
@export var range_side_full_offset_y: Vector2 = Vector2(0.0, 4.0)
var start_left_pos: Vector2 = Vector2()
var start_right_pos: Vector2 = Vector2()
@export var range_max_full_open_close_time: Vector2 = Vector2(1.8, 3.6)
var full_open_offset: Vector2
# ---------------------------- full open params ----------------------------------------

func _ready() -> void:
	origin_left = curtain_left.position
	origin_right = curtain_right.position
	
	little_open_offset = Vector2(
		randf_range(range_side_offset_x.x, range_side_offset_x.y),
		randf_range(range_side_offset_y.x, range_side_offset_y.y)
	)
	
	full_open_offset = Vector2(
		randf_range(range_side_full_offset_x.x, range_side_full_offset_x.y),
		randf_range(range_side_full_offset_y.x, range_side_full_offset_y.y)
	)

func _process(delta: float) -> void:
	match _state:
		CurtainSystemState.OPENING_A_LITTLE: _update_little_opening(delta)
		CurtainSystemState.CLOSING_A_LITTLE: _update_little_closing(delta)
		CurtainSystemState.OPENING_FULL: _update_full_opening(delta)
		CurtainSystemState.CLOSING_FULL: _update_full_closing(delta)

func _update_full_opening(delta: float) -> void:
	time = min(time + delta, max_time)
	_update_full_opening_params()
	if time == max_time: _state = CurtainSystemState.OPEN_FULL
	
func _update_full_closing(delta: float) -> void:
	time = max(time - delta, 0.0)
	_update_full_closing_params()
	if time == 0.0:
		on_close.emit()
		_state = CurtainSystemState.CLOSED
	
func _update_full_opening_params() -> void:
	var t: float = time / max_time
	var alpha: float = TweenUtils.ease_out_quart(t)
	
	var lerp_left: Vector2 = lerp(
		start_left_pos,
		origin_left - full_open_offset,
		alpha
	)
	
	var lerp_right: Vector2 = lerp(
		start_right_pos,
		origin_right + full_open_offset,
		alpha
	)
	
	curtain_left.position = lerp_left
	curtain_right.position = lerp_right
	
func _update_full_closing_params() -> void:
	var t: float = 1.0 - time / max_time
	var alpha: float = TweenUtils.ease_out_quart(t)
	
	var lerp_left: Vector2 = lerp(
		start_left_pos,
		origin_left,
		alpha
	)
	
	var lerp_right: Vector2 = lerp(
		start_right_pos,
		origin_right,
		alpha
	)
	
	curtain_left.position = lerp_left
	curtain_right.position = lerp_right
	
func _update_little_opening(delta: float) -> void:
	time = min(time + delta, max_time)
	_update_little()
	if time == max_time: _state = CurtainSystemState.OPEN_A_LITTLE
	
func _update_little_closing(delta: float) -> void:
	time = max(time - delta, 0.0)
	_update_little()
	if time == 0.0: _state = CurtainSystemState.CLOSED

func _update_little() -> void:
	var t: float = time / max_time
	var alpha: float = TweenUtils.ease_out_quart(t)
	
	var delta_offset: Vector2 = lerp(
		Vector2.ZERO,
		little_open_offset,
		alpha
	)
	
	curtain_left.position = origin_left - delta_offset
	curtain_right.position = origin_right + delta_offset

func open_full() -> void:
	if locked: return
	
	var skip: bool = _state == CurtainSystemState.OPENING_FULL || _state == CurtainSystemState.OPEN_FULL
	if skip: return
	
	if _state == CurtainSystemState.CLOSED:
		on_opening.emit() # used by pauss
	
	ajust_full_open_origin()
	time = 0.0
	max_time = randf_range(range_max_full_open_close_time.x, range_max_full_open_close_time.y)
	curtain_left.start_full_sound()
	curtain_right.start_full_sound()
		
	_state = CurtainSystemState.OPENING_FULL
	
func close_full() -> void:
	if locked: return
	
	var skip: bool = _state == CurtainSystemState.CLOSING_FULL || _state == CurtainSystemState.CLOSED
	if skip: return
	
	ajust_full_open_origin()
	curtain_left.start_full_sound()
	curtain_right.start_full_sound()
	
	_state = CurtainSystemState.CLOSING_FULL

func ajust_full_open_origin() -> void:
	start_left_pos.x = curtain_left.position.x
	start_left_pos.y = curtain_left.position.y
	start_right_pos.x = curtain_right.position.x
	start_right_pos.y = curtain_right.position.y
	

func open_both_certains_a_little() -> void:
	if locked: return
	
	var skip: bool = !(_state == CurtainSystemState.CLOSED || _state == CurtainSystemState.CLOSING_A_LITTLE)
	if skip: return
	
	time = 0.0
	max_time = randf_range(range_max_open_close_time.x, range_max_open_close_time.y)
	curtain_left.start_little_sound()
	curtain_right.start_little_sound()
	
	_state = CurtainSystemState.OPENING_A_LITTLE
	
func close_both_certains_a_little() -> void:
	if locked: return
	
	var skip: bool = !(_state == CurtainSystemState.OPEN_A_LITTLE || _state == CurtainSystemState.OPENING_A_LITTLE)
	if skip: return
	
	curtain_left.start_little_sound()
	curtain_right.start_little_sound()
	
	_state = CurtainSystemState.CLOSING_A_LITTLE

func opened() -> bool:
	return _state == CurtainSystemState.OPEN_FULL
	
func closed() -> bool:
	return _state == CurtainSystemState.CLOSED
	
func lock() -> void:
	locked = true
