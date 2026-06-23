extends Area2D

func _ready() -> void:
	collision_layer = 0;
	collision_mask = CollisionConfig.PLAYER_COLLISION_PHYSIC_ID
	
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D	) -> void:
	print("You have entered the exit area")	
