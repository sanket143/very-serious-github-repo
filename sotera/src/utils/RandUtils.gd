# helper function holder class
class_name RandUtils

static var rand:RandomNumberGenerator = RandomNumberGenerator.new()

#Dummy constructor to prevent idiots calling .new()
func _init() -> void:
	assert(false, "Use RandUtils.target_function() instead")

#Me rewriting the RandomNumberGenerator functions but static this time
#If there's an easier way to do this please rewrite
static func randf()->float: #[0,1]
	return rand.randf()

static func randf_range(from: float, to: float)->float:
	return rand.randf_range(from,to)

static func randi_range(from:int, to:int)->int:
	return rand.randi_range(from, to)
