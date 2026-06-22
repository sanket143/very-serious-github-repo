# Make autoload?
extends Node

const _STREAM_COUNT : int = 4
const _MIN_VOLUME_DB : float = -60.0

# Instantiate music file paths
# ...
#

var _curr_idx : int = 0
var _players : Array[AudioStreamPlayer]
var _queued_track = null


func _ready() -> void:
	for i in _STREAM_COUNT:
		var instance : AudioStreamPlayer = AudioStreamPlayer.new()
		instance.bus = "Music"
		_players.push_back(instance)
		add_child(instance)


func stop_track(duration : float = 0.0) -> void:
	# Fadeout current track
	var fade_tween : Tween = get_tree().create_tween()
	fade_tween.tween_property(_players[_curr_idx], "volume_db", _MIN_VOLUME_DB, duration)
	fade_tween.tween_callback(_players[_curr_idx].stop)

	_curr_idx = (_curr_idx + 1) % _STREAM_COUNT


func play_track(track : AudioStream, duration : float = 0.0, from_pos : float = 0.0) -> void:
	# Wait for fade if any
	_players[_curr_idx].stop()
	_players[_curr_idx].volume_db = _MIN_VOLUME_DB

	var fade_tween : Tween = get_tree().create_tween()
	fade_tween.tween_property(_players[_curr_idx], "volume_db", 0.0, duration)

	# Start the new track
	_players[_curr_idx].stream = track
	_players[_curr_idx].play(from_pos)


func pause_track() -> void:
	_players[_curr_idx].stream_paused = true


func resume_track() -> void:
	_players[_curr_idx].stream_paused = false


func queue_track(id):
	_queued_track = id
	
	if not _players[_curr_idx].finished.is_connected(_on_track_finished):
		_players[_curr_idx].finished.connect(_on_track_finished)

func _on_track_finished():
	if _queued_track != null:
		var next_track = _queued_track
		_queued_track = null
		play_track(next_track, 0.0)
