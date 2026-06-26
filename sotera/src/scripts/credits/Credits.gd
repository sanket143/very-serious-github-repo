extends Node

@export var color_1st_line: Color
@export var color_2nd_line: Color

var prefab = preload("res://assets/prefabs/CreditBox.tscn")
var credits_path: String = "res://assets/meta/credits_lits.json"

func _ready() -> void:
	_spawn_contributors()
	MusicPlayer.stop_track(1.0)
	MusicPlayer.play_track(MusicPlayer.CREDITS_THEME, 1.0, 0.0, -7.5)
	
func _spawn_contributors() -> void:
	var json: Array = AssetsUtils.parse_array_json_res(credits_path)
	
	for i: int in range(50):
		var data = json[i]
		var instance: CreditsBox = prefab.instantiate()
		
		var color: Color = color_1st_line if i % 2 == 0 else color_2nd_line
		# data["joined_at"] ignorred
		instance.set_data(color, data["name"], data["discord_name"], data["roles"])

		add_child(instance)
