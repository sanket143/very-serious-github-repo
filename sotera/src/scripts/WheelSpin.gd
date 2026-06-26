extends Node2D

enum WHEELSTATE {
	SPINNING, # goes to WAIT_CURTAINS_TO_CLOSE
	COMPLETE, # We'll allow spinning only once
	IDLE,
	WAIT_CURTAINS_TO_CLOSE
}

var state: WHEELSTATE = WHEELSTATE.IDLE;
var offset: float = 0.0;
var spin_speed: float = 0.0;
var spin_time: float = 0.0;
var min_speed: float = 0.1;
var max_speed: float = 0.2;
var min_time: float = 3.0;
var max_time: float = 5.0;

var speed_multiplier: float = 0.0;

var items: Array[String] = [
	"maze", "bullet", "scary", "quiz", "story"
]
var itemSceneMap = {
	"maze": "res://assets/scenes/StandardMaze.tscn",
	"bullet": "res://assets/scenes/BulletHellMinigame.tscn",
	"scary": "res://assets/scenes/ScaryMaze.tscn"
}

var elapsed_spin_time = 0;
var single_value_height_in_texture = 1.0 / items.size();
var value_idx = 2;

@export var curtains: CurtainSystem
@export var minigame_tracker: MiniGameTracker

func _ready() -> void:
	offset = Events.get_spinner_start_offset()

func _process(delta: float) -> void:
	match state:
		WHEELSTATE.IDLE: return
		WHEELSTATE.WAIT_CURTAINS_TO_CLOSE: check_if_curtains_are_closed()

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
			if($WheelSpinEffect.state != $WheelSpinEffect.WheelPEState.SPEED_DOWN_TRANSITION):
				$WheelSpinEffect.stop_pe_impact()
			if($WheelSpinEffect2.state != $WheelSpinEffect2.WheelPEState.SPEED_DOWN_TRANSITION):
				$WheelSpinEffect2.stop_pe_impact()
	else: stop_spinning()

	value_idx = (int((offset + 0.1) / single_value_height_in_texture) + floori(items.size() / 2)) % items.size();

	$WheelTexture.material.set_shader_parameter("offset", offset);
	$WheelValue.text = str(items[value_idx])

func start_spinning():
	if state == WHEELSTATE.IDLE:
		state = WHEELSTATE.SPINNING
		spin_speed = min_speed # RandUtils.randf_range(min_speed, max_speed)
		spin_time = min_time # RandUtils.randf_range(min_time, max_time)
		elapsed_spin_time = 0

		SoundPool.play_sound(SoundPool.WHEEL_START)

		$WheelSpinEffect.start_speedup()
		$WheelSpinEffect2.start_speedup()
	
		await get_tree().create_timer(spin_time * 0.45).timeout
	
		SoundPool.play_sound(SoundPool.WHEEL_STOP)

func check_if_curtains_are_closed() -> void:
	if !curtains.closed(): return
	
	SoundPool.play_sound(SoundPool.MINIGAME_SELECTED)
	Events.change_level(itemSceneMap[str(items[value_idx])])
	
	state = WHEELSTATE.COMPLETE
	
func stop_spinning() -> void:
	if state == WHEELSTATE.SPINNING: 
		var winning_game = items[value_idx]
		
		if minigame_tracker:
			minigame_tracker.add_minigame(winning_game)
		
		start_closing_curtains()	


		
func start_closing_curtains() -> void:
	state = WHEELSTATE.WAIT_CURTAINS_TO_CLOSE # old: WHEELSTATE.COMPLETED
	Events.increase_spinner_starting_positoin()
	$WheelSpinEffect.start_slowdown()
	$WheelSpinEffect2.start_slowdown()
	curtains.close_full()
	SoundPool.stop_sound(SoundPool.AUDIENCE_CHEER, 5.0)

func _on_lever_lever_pulled() -> void:
	start_spinning()
	SoundPool.play_sound(SoundPool.LEVER_PULL)
	SoundPool.play_sound(SoundPool.AUDIENCE_CHEER)
