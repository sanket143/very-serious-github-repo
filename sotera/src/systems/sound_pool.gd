# Make autoload?
extends Node

const _STREAM_COUNT : int = 64
const _MAX_TRIES : int = 10

# Instantiate file paths here

# e.g. const SOUND_GAME_OVER : AudioStream = preload("res://assets/audio/sfx/game_over_123.mp3")

# const SOUND_FOOTSTEP_1 : AudioSteam = preload("res://assets/audio/sfx/footstep_1.mp3")
# const SOUND_FOOTSTEP_2 : AudioSteam = preload("res://assets/audio/sfx/footstep_2.mp3")
# const SOUND_FOOTSTEPS : Array[AudioStream] = [
	#SOUND_FOOTSTEP_1,
	#SOUND_FOOTSTEP_2,
#]

#

# Concurrency: how many sounds of the same type can play at the same time
const _SOUND_CONCURRENCY : Dictionary = {

} 

const _SOUND_DEFAULT_CONCURRENCY : int = 3

var _next_idx : int = 0
var _players : Array[AudioStreamPlayer]


func _ready() -> void:
	for i in _STREAM_COUNT:
		var instance : AudioStreamPlayer = AudioStreamPlayer.new()
		_players.push_back(instance)
		add_child(instance)


func _get_max_concurrent(sound : AudioStream) -> int:
	if sound in _SOUND_CONCURRENCY:
		return _SOUND_CONCURRENCY[sound]
	
	# Separately check for sounds that are grouped with variants

# e.g.
	#if sound in SOUND_FOOTSTEPS:
		#return 2

	return _SOUND_DEFAULT_CONCURRENCY


func play_sound(sound : AudioStream) -> void:
	var max_concurrent : int = _get_max_concurrent(sound)
	
	var playing_instances : Array[AudioStreamPlayer] = []
	for p in _players:
		if p.stream == sound and p.playing:
			playing_instances.append(p)
	
	# Stop oldest instance if at max concurrency
	if playing_instances.size() >= max_concurrent:
		playing_instances[0].stop()
	
	var num_tries : int = 0
	while num_tries < _MAX_TRIES:
		if not _players[_next_idx].playing:
			_players[_next_idx].stream = sound
			_apply_custom_sound_volume(_players[_next_idx], sound)
			_apply_pitch_modulation(_players[_next_idx], sound)
			_players[_next_idx].play()
			_next_idx = (_next_idx + 1) % _STREAM_COUNT
			break
		else:
			num_tries += 1
			_next_idx = (_next_idx + 1) % _STREAM_COUNT


func stop_sound(sound : AudioStream) -> void:
	for p in _players:
		if p.stream == sound:
			p.stop()


func stop_all_sounds():
	for p in _players:
		p.stop()


# Volume control
func _apply_custom_sound_volume(player : AudioStreamPlayer, _sound : AudioStream) -> void:
	player.volume_db = 0.0
	#if _sound == SOUND_GAME_OVER:
		#player.volume_db = randf_range(-8.0, -6.5)
		#return
	
	return


# Pitch control
func _apply_pitch_modulation(player : AudioStreamPlayer, _sound : AudioStream) -> void:
	#if _sound in SOUND_FOOTSTEPS:
		#player.pitch_scale = randf_range(0.98, 1.1)
		#return
	
	return
