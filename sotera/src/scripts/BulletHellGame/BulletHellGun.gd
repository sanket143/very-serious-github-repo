extends Node2D
class_name BulletHellGun


@export var bulletScene:PackedScene
@export var firerate:float
var preloadedBullets:Array[BulletHellBullet]

func shoot(mousePos:Vector2):
	if $FireRate.is_stopped():
		getBullet().shoot(mousePos)
		$FireRate.start(1.0/firerate)
	

func getBullet()->BulletHellBullet:
	for b in preloadedBullets:
		if b.state == BulletHellBullet.BULLETSTATE.DISABLED:
			b.position = global_position
			return b
	var toAdd = bulletScene.instantiate()
	toAdd.position = global_position
	get_node("/root/BulletHellMinigame").add_child(toAdd)
	preloadedBullets.append(toAdd)
	return toAdd
