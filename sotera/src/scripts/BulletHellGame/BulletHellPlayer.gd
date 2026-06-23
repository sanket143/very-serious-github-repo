extends CharacterBody2D
class_name BulletHellCharacter

@export var speed = 500
@export var gun:BulletHellGun
@export var iFrames:int
@export var maxHp:int

@onready var hp = maxHp
var currentiFrames = 0
var mousePos
var theta = 0
var firing = false

const up_left_theta:float = (-3)*PI/4
const up_right_theta:float = -PI/4
const down_right_theta = PI/4
const down_left_theta = 3*PI/4
const up_theta = -PI/2
const down_theta = PI/2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		firing = true
	if event.is_action_released("action"):
		firing = false
	
#Starting screen parameters
func _ready():
	$Animations.play("forwardidle")
	mousePos = get_viewport().get_mouse_position()
	
func player_movement():
#player movement
	var direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	velocity = direction * speed
	
	
func idle_animation():
	if theta>down_right_theta && theta<down_left_theta:
		$Animations.play("forwardidle")
	if theta<up_right_theta&&theta>up_left_theta:
		$Animations.play("backidle")
	if theta > down_left_theta || theta<up_left_theta:
		$Animations.play("leftidle")
	if theta < down_right_theta && theta > up_right_theta:
		$Animations.play("rightidle")
		
func movement_animation():
	if velocity.x == 0 and velocity.y > 0:
		if theta>0:
			$Animations.play("forwardrun")
		else:
			$Animations.play("backrun_reverse")
	elif velocity.x == 0 and velocity.y < 0:
		if theta>0:
			$Animations.play("forwardrun_reverse")
		else:
			$Animations.play("backrun")
	elif velocity.x > 0:
		if theta>up_theta && theta<down_theta:
			$Animations.play("rightrun")
		else:
			$Animations.play("leftrun_reverse")
	elif velocity.x < 0:
		if theta>up_theta && theta<down_theta:
			$Animations.play("rightrun_reverse")
		else:
			$Animations.play("leftrun")

func _physics_process(delta):
	if currentiFrames>0:
		currentiFrames -= 1
	mousePos = get_global_mouse_position()
	theta = get_angle_to(mousePos)
	if firing:
		gun.shoot(mousePos)
	player_movement()
	
	#player animations
	if velocity == Vector2.ZERO:
		idle_animation()

	else:
		movement_animation()
		
	move_and_slide()

#frame perfect / footsteps
func _on_animations_frame_changed():
	if $Animations.animation in ["forwardrun", "leftrun", "rightrun", "backrun"]:
		if $Animations.frame in [0, 4]:
			$Footsteps.play()
			
	else:
		$Footsteps.stop()
		
func takeDamage(damage:int)->void:
	
	if currentiFrames<=0:
		currentiFrames = iFrames
		hp-=damage
		
	if hp<=0:
		#Minigame over
		print("Player Dead")
		takeDamage(0)#crashing the game on death for funsies	
	
