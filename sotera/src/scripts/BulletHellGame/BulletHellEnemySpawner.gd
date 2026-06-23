extends Node

@export var enemyScene:PackedScene
@export var player:BulletHellCharacter
@export var spawnerLocations:Array[Node2D]
@export var waves:Array[int]
var currentWave:int = 0
var enemiesSpawned = 0
var enemiesKilled:int = 0
var enemies:Array[BulletHellEnemy]

func _ready() -> void:
	startWave()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func getNewEnemy()->BulletHellEnemy:
	for e in enemies:
		if e.isDisabled():
			return e
	var toAdd = enemyScene.instantiate()
	toAdd.enemyKilled.connect(onEnemyKilled)
	get_node("/root/BulletHellMinigame").add_child(toAdd)
	enemies.append(toAdd)
	return toAdd

func onEnemyKilled(enemy:BulletHellEnemy)->void:
	enemiesKilled+=1
	if enemiesKilled>=waves[currentWave]:
		currentWave+=1
		if currentWave>=waves.size():
			#drop contract
			return
		$WaveDelay.start()
		
func startWave()->void:
	enemiesSpawned = 0 
	enemiesKilled = 0
	$WaveCounter.text = "Wave: "+ str(currentWave+1)
	$SpawnCooldown.start()

func spawnEnemy()->void:
	if enemiesSpawned <  waves[currentWave]:
		var i = RandUtils.randi_range(0,spawnerLocations.size()-1)
		var spawnPos = spawnerLocations[i].position
		getNewEnemy().spawn(spawnPos,player)
		enemiesSpawned+=1
		$SpawnCooldown.start()
