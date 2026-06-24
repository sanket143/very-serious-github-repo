extends CharacterBody2D

var speed = 500
var lastvel = Vector2.ZERO

@onready var dust_vfx = $Dust

#Starting screen parameters
func _ready():
	$Animations.play("forwardidle")

func player_movement():
#player movement
	var direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	velocity = direction * speed
	if velocity != Vector2.ZERO:
		lastvel = velocity
	
func idle_animation():
	if lastvel.x == 0 and lastvel.y > 0:
		$Animations.play("forwardidle")
	if lastvel.x == 0 and lastvel.y < 0:
		$Animations.play("backidle")
	if lastvel.x > 0:
		$Animations.play("rightidle")
	if lastvel.x < 0:
		$Animations.play("leftidle")
		
func movement_animation():
	$Animations.flip_h = false
	if velocity.x == 0 and velocity.y > 0:
		$Animations.play("forwardrun")
	elif velocity.x == 0 and velocity.y < 0:
		$Animations.play("backrun")
	elif velocity.x > 0:
		$Animations.play("rightrun")
	elif velocity.x < 0:
		$Animations.flip_h = true
		$Animations.play("leftrun")

func _physics_process(_delta):
	player_movement()
	
	if velocity == Vector2.ZERO:
		idle_animation()
		if dust_vfx:
			dust_vfx._on_player_stop_moving()
	else:
		movement_animation()
		if dust_vfx:
			dust_vfx._on_player_start_moving()
		
	move_and_slide()

#frame perfect / footsteps
func _on_animations_frame_changed():
	if $Animations.animation in ["forwardrun", "leftrun", "rightrun", "backrun"]:
		if $Animations.frame in [0, 4]:
			$Footsteps.play()
	else:
		$Footsteps.stop()
