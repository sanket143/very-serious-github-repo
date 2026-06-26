extends SpineSprite

class_name JumpScareController

const TRACK_ID: int = 0

enum JumpscareControllerState{ HIDDEN, JUMP }
enum JumpscareType{ HAND_ONLY, AAAA, HAND_SCREEN_DRAG, SUPRISE_CHECK }

var _state_animation_link: Dictionary[JumpscareType, RangeTrack] = {
	JumpscareType.HAND_ONLY: JumpscareAnimationConfig.HAND_JUMP,
	JumpscareType.AAAA: JumpscareAnimationConfig.JUMP,
	JumpscareType.HAND_SCREEN_DRAG: JumpscareAnimationConfig.JUMP_LOOK,
	JumpscareType.SUPRISE_CHECK: JumpscareAnimationConfig.JUMP_NO_HANDS
}

signal jumpscare_finished

@onready var anime_state: SpineAnimationState = get_animation_state()
@onready var voice: AudioStreamPlayer2D = $Voice

var _state = JumpscareControllerState.HIDDEN

func _process(delta: float) -> void:
	if _state == JumpscareControllerState.HIDDEN: return
	
	# check if track of jumpscare is completed -> then turn off
	var track: SpineTrackEntry = anime_state.get_track(TRACK_ID)
	if track.is_complete(): stop_jumpscare()
	
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
	_init_voice()
	visible = true
	_state = JumpscareControllerState.JUMP
	
func _init_voice() -> void:
	SoundPool.play_random_sound(SoundPool.JUMPSCARE)
	
func stop_jumpscare() -> void:
	visible = false
	_state = JumpscareControllerState.HIDDEN
	jumpscare_finished.emit()
