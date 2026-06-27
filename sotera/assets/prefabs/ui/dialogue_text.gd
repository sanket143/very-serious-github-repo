extends Control
class_name Dialogue

signal speech_ended
signal speech_started

enum UiTextState {SHOWTEXT, NO_TEXT}

var state: UiTextState = UiTextState.NO_TEXT
var current_dialogue_lines: Array[String] = []
var current_line_idx: int = 0
var timer: float = 0.0
var is_typing: bool = false
var typing_speed: float = 0.05

# cache text in progress to be shown
# cached because there is option to skip/auto complete sentence by clicking on button
var _show_text: PackedStringArray
var _skip_show_text: bool # to break for loop which adds characters from outside
var _char_track_index: int # to know how to finish text line from _show_text

@onready var label: Label = $Label

func _ready() -> void:
	label.text = "" # reset placeholder text from Editor
	_skip_show_text = false

func _process(delta: float) -> void:
	if state == UiTextState.NO_TEXT or is_typing:
		return

	timer = max(timer - delta, 0.0)
	if timer == 0.0: _advance_line()

func _advance_line() -> void:
	label.text = ""
	current_line_idx += 1

	var next_line = _get_current_line()

	if next_line == null:
		# No more lines — hide everything
		on_stop_dialogue()
		return

	_show_line(next_line)

func _get_current_line() -> Variant:
	if len(current_dialogue_lines) == 0:
		return null
	if current_line_idx >= current_dialogue_lines.size():
		return null
	return current_dialogue_lines[current_line_idx]

func _show_line(line: String) -> void:
	is_typing = true
	_show_text = line.replace('"', "").split()
	
	_char_track_index = 0
	for idx in _show_text:
		if _skip_show_text:
			_skip_show_text = false # reset
			break # exit for loop from outside
		
		_char_track_index += 1 # outside loop has to finish text
		_append_line_character(idx)

		await get_tree().create_timer(typing_speed).timeout # wait to write next character
	
	timer = 0.5
	is_typing = false

func _append_line_character(c) -> void:
	label.text = label.text + c
	SoundPool.play_random_shuffled_sound(SoundPool.DIALOGUE_NOISES_STEVE)
		
func _divide_into_setence_chunks(v: String, max_characters):
	v = v.replace('"', "")
	var no_of_chars = int(len(v) / max_characters)
	if no_of_chars == 0:
		return [v]
	else:
		var regex = RegEx.new()
		regex.compile("[^.!]+(?:[.!]+)?")
		var sentences = regex.search_all(v).map(func(val): return val.get_string())
		var new_sentences = [""]
		var current_idx = 0
		for sentence in sentences:
			var appended_s = new_sentences[current_idx] + sentence
			if len(appended_s) <= max_characters:
				new_sentences[current_idx] = appended_s
			else:
				new_sentences.append(sentence)
				current_idx += 1
		return new_sentences

func _flat_map(arr: Array) -> Array[String]: # 2 level deep only
	var flat_arr: Array[String] = []
	for nested_arr in arr:
		for v in nested_arr:
			flat_arr.append(v)
	return flat_arr

func on_start_dialogue(dialogue: DialogueJSON, max_characters) -> void:
	var dialogue_lines = dialogue.dialogue_lines.map(func(v): return _divide_into_setence_chunks(v, max_characters))
	
	var untyped_dialogues = _flat_map(dialogue_lines)
	untyped_dialogues = untyped_dialogues.map(func(sentence): return sentence.strip_edges())
	var dialogues: Array[String] = []
	
	for v in untyped_dialogues:
		dialogues.append(str(v))
	current_dialogue_lines = dialogues

	current_line_idx = 0
	timer = 0.0
	state = UiTextState.SHOWTEXT
	visible = true

	var first_line = _get_current_line()
	if first_line == null:
		on_stop_dialogue()
		return

	_show_line(first_line)

func on_stop_dialogue() -> void:
	state = UiTextState.NO_TEXT
	visible = false
	current_dialogue_lines = []
	current_line_idx = 0
	timer = 0.0
	speech_ended.emit()
	
func _input(e: InputEvent) -> void:
	var action_skip_dialogue_line: bool = e is InputEventKey and e.keycode == KEY_SPACE and !e.pressed
	if action_skip_dialogue_line: _skip_dialogue_line()

# 1 ... function tries to finish line
# 2 ... if line finished, start new line
func _skip_dialogue_line() -> void:
	if state == UiTextState.NO_TEXT: return # if no dialogue go out
	
	_skip_show_text = true
	
	# ----------------------- fill text -----------------------------
	var rn = range(_char_track_index + 1, _show_text.size())
	for i in rn:
		var idx = _show_text[i]
		_append_line_character(idx)
	# ----------------------- fill text -----------------------------
	
	# TODO add block_timer option (so timer do not count down to next character)

func is_finished() -> bool:
	return state == UiTextState.NO_TEXT
	
func start_next_dialog() -> void:
	if Globals.Total_contracts == 0:
		var dialogs = load("res://assets/narrative/dialogue/Scene_intro.tres")
		on_start_dialogue(dialogs, 100)
		speech_started.emit()
	elif Globals.Total_contracts == 1:
		var dialogs = load("res://assets/narrative/dialogue/one_contract.tres")
		on_start_dialogue(dialogs, 100)
		speech_started.emit()
	elif Globals.Total_contracts == 2:
		var dialogs = load("res://assets/narrative/dialogue/two_contract.tres")
		on_start_dialogue(dialogs, 100)
		speech_started.emit()
	elif Globals.Total_contracts == 3:
		var dialogs = load("res://assets/narrative/dialogue/boss_intro.tres")
		on_start_dialogue(dialogs, 100)
		speech_started.emit()

	# # dirty fix
	# if Globals.Total_contracts != 0:
	# 	on_stop_dialogue()
