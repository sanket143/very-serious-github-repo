extends CharacterBody2D
class_name BulletHellEnemy

#@export var meleeRange:float
@export var melee:Node2D
@export var navAgent:NavigationAgent2D
@export var movementSpeed: float = 200.0
@export var maxHp:int
@export var damage:int
@onready var hp = maxHp
var player:BulletHellCharacter
var spawnPos:Vector2
var damagingPlayer = false

var state:BHENEMYSTATE = BHENEMYSTATE.DISABLED

signal enemyKilled(enemy:BulletHellEnemy)

enum BHENEMYSTATE{
	DISABLED,
	MOVING,
	ATTACKING
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#navAgent.set_target_desired_distance(m)
	actor_setup.call_deferred()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(player.position)

func set_movement_target(movement_target: Vector2):
	navAgent.target_position = movement_target


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state !=BHENEMYSTATE.DISABLED:
		set_movement_target(player.position)
	match state:
		BHENEMYSTATE.ATTACKING:
			velocity = Vector2.ZERO
			if damagingPlayer:
				player.takeDamage(damage)
		BHENEMYSTATE.DISABLED:
			velocity = Vector2.ZERO
		BHENEMYSTATE.MOVING:
			if navAgent.is_target_reached():
				return
			
			var currentAgentPosition: Vector2 = global_position
			var nextPathPosition: Vector2 = navAgent.get_next_path_position()
			velocity = currentAgentPosition.direction_to(nextPathPosition) * movementSpeed
			melee.look_at(global_position+velocity)
			
	move_and_slide()

func spawn(spawnPos:Vector2,player:BulletHellCharacter)->void:
	state = BHENEMYSTATE.MOVING
	self.spawnPos = spawnPos
	position = spawnPos
	self.player = player
	$Animation.show()
	pass
	
func takeDamage(damageToTake:int)->void:
	hp-=damageToTake
	if hp<=0:
		destroy()
	pass

func isDisabled() -> bool:
	return state == BHENEMYSTATE.DISABLED
	
func destroy()->void:
	state = BHENEMYSTATE.DISABLED
	position = spawnPos
	emit_signal("enemyKilled",self)
	$Animation.hide()

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body is BulletHellCharacter:
		if state == BHENEMYSTATE.MOVING:
			state = BHENEMYSTATE.ATTACKING
			damagingPlayer = true


func _on_attack_hitbox_body_exited(body: Node2D) -> void:
	if body is BulletHellCharacter:
		if state==BHENEMYSTATE.ATTACKING:
			damagingPlayer = false
			state = BHENEMYSTATE.MOVING
		
