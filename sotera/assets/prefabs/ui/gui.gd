extends CanvasLayer

var width = 60;
var height = 18;
var total_hearts = 3;

@onready var heart:TextureRect = $"Hearts/heart" 
@onready var contract_label:Label = $"Contracts/count"

func get_heart_region(lives) -> Rect2:
	if lives < 0:
		return Rect2(16,0,15,18)
	var unit = 18
	var aaa = ( total_hearts + 1 ) - lives 
	var y = (aaa) * unit;
	return Rect2(0, y, width, height)

func _ready() -> void:
	heart.texture.region = get_heart_region(Globals.Lives)
	heart.stretch_mode = TextureRect.STRETCH_KEEP
	
	contract_label.text = str(Globals.Total_contracts)

	Events.collect_contract.connect(update_gui)
	Events.loose_life.connect(update_gui)

func update_gui() -> void:
	heart.texture.region = get_heart_region(Globals.Lives)
	contract_label.text = str(Globals.Total_contracts)
