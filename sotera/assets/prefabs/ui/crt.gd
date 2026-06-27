extends Control

class_name CrtControl

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var crt_motion: CrtMotion

@onready var loading: ColorRect = $LoadingScreen


func _ready() -> void:
	crt_motion = CrtMotion.new($ColorRect)
	adjust_to_full_screen()
	
	Events.level_change_start.connect(fade_out)
	Events.level_change_enter.connect(fade_in)
	Events.play_loading_screen.connect(load_screen)
	Events.stop_loading_screen.connect(stop_load_screen)
	
	loading.color.a = 1.0

func _process(delta: float) -> void:
	crt_motion.update(delta)

func fade_out() -> void:
	animation_player.play("fade_to_black")
	# Wait until screen is black
	await animation_player.animation_finished
	Events.fade_out_done.emit()

func fade_in() -> void:
	animation_player.play_backwards("fade_to_black")
	await animation_player.animation_finished

func load_screen() -> void:
	# Show black screen
	loading.show()

func stop_load_screen() -> void:
	# Hides black screen
	loading.hide()

func adjust_to_full_screen() -> void:
	var full_screen_size: Vector2 = get_viewport_rect().size
	var zero: Vector2 = Vector2.ZERO
	
	position = zero
	$ColorRect.position = zero
	$ColorRect2.position = zero
	
	size = full_screen_size
	$ColorRect.size = full_screen_size
	$ColorRect2.size = full_screen_size
	
func start_darken(focus_origin: Vector2) -> void:
	crt_motion.start_darken(focus_origin)
	
func stop_darken() -> void:
	crt_motion.start_lighten()
	
func dark_flick(available_time: float) -> void:
	var rect: ColorRect = $ColorRect2
	rect.visible = true
	rect.color = Color(0,0,0,1)
	
	var tween = create_tween()
	var wait_30_percents: float = available_time * 0.18
	var left_time: float = available_time - wait_30_percents

	#tween.tween_property(rect, "color:a", 1.0, 0.0) # insatnt
	tween.tween_interval(wait_30_percents) # wait_30_percents dark
	tween.tween_property(rect, "color:a", 0.5, left_time) # go to 1.0 -> 0.5 in left_time
	
func reset() -> void:
	crt_motion.reset()
