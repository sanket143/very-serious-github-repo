extends SpineSprite

class_name JumpScareController

const TRACK_ID: int = 0

enum JumpscareControllerState{ 
	HIDDEN,
	JUMP,
	GAME_OVER_HAND_RISE,
	GAME_OVER_HAND_IDLE
}

enum JumpscareType{ 
	HAND_ONLY, AAAA, HAND_SCREEN_DRAG, SUPRISE_CHECK, # jumpscares
	HAND_RISE, HAND_IDLE # game over fixed state
}

var _state_animation_link: Dictionary[JumpscareType, RangeTrack] = {
	JumpscareType.HAND_ONLY: JumpscareAnimationConfig.HAND_JUMP,
	JumpscareType.AAAA: JumpscareAnimationConfig.JUMP,
	JumpscareType.HAND_SCREEN_DRAG: JumpscareAnimationConfig.JUMP_LOOK,
	JumpscareType.SUPRISE_CHECK: JumpscareAnimationConfig.JUMP_NO_HANDS,
	JumpscareType.HAND_RISE: JumpscareAnimationConfig.HAND_RISE,
	JumpscareType.HAND_IDLE: JumpscareAnimationConfig.HAND_IDLE
}

signal jumpscare_finished

@onready var anime_state: SpineAnimationState = get_animation_state()
@onready var voice: AudioStreamPlayer2D = $Voice

var _state: JumpscareControllerState = JumpscareControllerState.HIDDEN

func _process(delta: float) -> void:
	match _state:
		JumpscareControllerState.HIDDEN: return
		JumpscareControllerState.JUMP: _check_stop_jumpscare()
		JumpscareControllerState.GAME_OVER_HAND_RISE: _check_go_to_idle()
		JumpscareControllerState.GAME_OVER_HAND_IDLE: pass # no function idle
		
func _check_go_to_idle() -> void:
	var track: SpineTrackEntry = anime_state.get_track(TRACK_ID)
	if track.is_complete(): _go_hand_idle()

func _check_stop_jumpscare() -> void:
	# check if track of jumpscare is completed -> then turn off
	var track: SpineTrackEntry = anime_state.get_track(TRACK_ID)
	if track.is_complete(): _go_hand_idle()


func _go_hand_idle() -> void:
	_set_animation(JumpscareType.HAND_IDLE)
	_state = JumpscareControllerState.GAME_OVER_HAND_IDLE

func _set_animation(type: JumpscareType) -> void:
	anime_state.clear_tracks()
	var track: RangeTrack = _state_animation_link[type]
	var speed: float = randf_range(track.min_speed(), track.max_speed())
	anime_state.set_animation(track.track(), track.loop(), TRACK_ID).set_time_scale(speed)
	
func start_jumpscare() -> void:
	jumpscare(JumpscareType.AAAA)

func start_check_jumpscare() -> void:
	jumpscare(JumpscareType.SUPRISE_CHECK)
	
func start_hand_screen_drag_jumpscare() -> void:
	jumpscare(JumpscareType.HAND_SCREEN_DRAG)
	
func start_hand_jumpscare() -> void:
	jumpscare(JumpscareType.HAND_ONLY)
	
func start_rand_jumpscare() -> void:
	var type: JumpscareType = _get_random_jumpscare_type()
	jumpscare(type)
	
func _get_random_jumpscare_type() -> JumpscareType:
	var types = JumpscareType.values()
	return types[randi() % types.size()]
	
func jumpscare(type: JumpscareType) -> void:
	_set_animation(type)
	#_init_voice()
	visible = true
	_state = JumpscareControllerState.JUMP

# Separating from controller to have as custom sound for each scare
#func _init_voice() -> void:
	#SoundPool.play_random_sound(SoundPool.JUMPSCARE) 
	
func stop_jumpscare() -> void:
	visible = false
	_state = JumpscareControllerState.HIDDEN
	jumpscare_finished.emit()
	
func start_hand_rise() -> void:
	_set_animation(JumpscareType.HAND_RISE)
	#anime_state.set_animation(JumpscareAnimationConfig.TOGGLE_TO_ONLY_HAND_RISE_VISIBLE.track(), false, 1)
	
	visible = true
	_state = JumpscareControllerState.GAME_OVER_HAND_RISE
