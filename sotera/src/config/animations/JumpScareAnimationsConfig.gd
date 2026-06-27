class_name JumpscareAnimationConfig

# todo: decide if params goes into json config -> if animations are not created by multiple tracks then there is no need
# reason: data is still simple to mantain hardcoded in code

#Dummy constructor to prevent idiots calling .new()
func _init() -> void:
	assert(false, "Use RandUtils.target_function() instead")

# somehow lock variable (block from editing) - TODO 
static var JUMP: RangeTrack = RangeTrack.new("Jump", 0.92, 1.08, false)
static var HAND_JUMP: RangeTrack = RangeTrack.new("Hand Only", 0.8, 0.98, false) 
static var JUMP_LOOK: RangeTrack = RangeTrack.new("Jump", 0.9, 1.15, false)
static var JUMP_NO_HANDS: RangeTrack = RangeTrack.new("Jump No Hands", 1.0, 1.11, false) 

# used for game over hand rise -> idle risen hand
static var HAND_RISE: RangeTrack = RangeTrack.new("Hand Up", 0.2, 0.24, false)
static var HAND_IDLE: RangeTrack = RangeTrack.new("Hand IDLE", 0.08, 0.12, true)


static var TOGGLE_TO_ONLY_HAND_RISE_VISIBLE: AnimeTrack = AnimeTrack.new("toggle_to_only_hand", 0.0, false)
