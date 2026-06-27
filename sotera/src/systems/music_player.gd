# music_player autoload
extends Node

const _STREAM_COUNT : int = 4
const _MIN_VOLUME_DB : float = -60.0

# Instantiate music file paths
const MAIN_THEME : AudioStream = preload("res://assets/audio/music/ost/main theme - Mayle96 (loop).ogg")
const STAGE_MUSIC : AudioStream = preload("res://assets/audio/music/ost/main theme - dart monke (adapted).ogg")
const MINIGAME : AudioStream = preload("res://assets/audio/music/ost/very serious noodle (adapted).mp3")
const SCARY : AudioStream = preload("res://assets/audio/music/ost/mini game theme - dart monke.ogg")
const BULLET_THEME : AudioStream = preload("res://assets/audio/music/ost/Marcyiscool Boss Battle (adapted).ogg")
const CREDITS_THEME : AudioStream = preload("res://assets/audio/music/ost/Marcyiscool Mini game D (adapted).ogg")
const FINAL_BATTLE : AudioStream = preload("res://assets/audio/music/ost/boss.mp3")
const GAME_OVER : AudioStream = preload("res://assets/audio/music/ost/Cheesy Game Over.ogg")

var _curr_idx : int = 0
var _players : Array[AudioStreamPlayer]
var _queued_track = null
var _queued_volume_db : float = 0.0

func _ready() -> void:
	for i in _STREAM_COUNT:
		var instance : AudioStreamPlayer = AudioStreamPlayer.new()
		_players.push_back(instance)
		add_child(instance)


func stop_track(duration : float = 0.0) -> void:
	# Fadeout current track
	var fade_tween : Tween = get_tree().create_tween()
	fade_tween.tween_property(_players[_curr_idx], "volume_db", _MIN_VOLUME_DB, duration)
	fade_tween.tween_callback(_players[_curr_idx].stop)

	_curr_idx = (_curr_idx + 1) % _STREAM_COUNT


func play_track(track : AudioStream, duration : float = 0.0, from_pos : float = 0.0, target_volume_db : float = 0.0) -> void:
	# Wait for fade if any
	
	_players[_curr_idx].stop()
	_players[_curr_idx].volume_db = _MIN_VOLUME_DB

	var fade_tween : Tween = get_tree().create_tween()
	fade_tween.tween_property(_players[_curr_idx], "volume_db", target_volume_db, duration)

	# Start the new track
	_players[_curr_idx].stream = track
	_players[_curr_idx].play(from_pos)


func pause_track() -> void:
	_players[_curr_idx].stream_paused = true


func resume_track() -> void:
	_players[_curr_idx].stream_paused = false


func queue_track(track : AudioStream, volume_db : float = 0.0) -> void:
	_queued_track = track
	_queued_volume_db = volume_db
	if not _players[_curr_idx].finished.is_connected(_on_track_finished):
		_players[_curr_idx].finished.connect(_on_track_finished)


func _on_track_finished():
	if _queued_track != null:
		var next_track = _queued_track
		_queued_track = null
		play_track(next_track, 0.0, 0.0, _queued_volume_db)
