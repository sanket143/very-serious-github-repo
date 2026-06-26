extends Control

enum Answers {A, B ,C, D}

@onready var option_a: Button = $Options/VBoxContainer/OptionA
@onready var option_b: Button = $Options/VBoxContainer/OptionB
@onready var option_c: Button = $Options/VBoxContainer2/OptionC
@onready var option_d: Button = $Options/VBoxContainer2/OptionD
@onready var question_label: Label = $QuestionLabel
@onready var boss_health_bar: ProgressBar = $BossHealthBar
@onready var boss_flash_component: FlashComponent = $BossFlashComponent
@onready var player_flash_component: FlashComponent = $PlayerFlashComponent
@onready var shake_camera_2d: Camera2D = $ShakeCamera2D


@export var boss_max_health: int
@export var player_damage: int
@export var questions: Array[Question]

var question_index: int = 0
var current_question: Question
var num_of_questions: int = 0
var boss_health: int

func _ready() -> void:
	num_of_questions = questions.size()
	if num_of_questions == 0:
		return
	questions.shuffle()
	
	option_a.grab_focus()
	var buttons = [option_a, option_b, option_c, option_d]
	for button in buttons:
		button.pressed.connect(_on_option_button_pressed.bind(buttons.find(button)))
		button.focus_entered.connect(func(): SoundPool.play_random_sound(SoundPool.UI_SELECT_BOSS))
		button.mouse_entered.connect(func(): SoundPool.play_random_sound(SoundPool.UI_SELECT_BOSS))

	display_question()
	set_health_bars()
	
	MusicPlayer.play_track(MusicPlayer.FINAL_BATTLE, 0.0, 0.0, -5.0)


func set_health_bars() -> void:
	boss_health = boss_max_health

	boss_health_bar.max_value = boss_max_health
	boss_health_bar.value = boss_health


func _on_option_button_pressed(answer: Answers) -> void:
	if answer == current_question.answer:
		on_right_answer()
	else:
		on_wrong_question()
	
	move_to_next_question()
	SoundPool.play_random_sound(SoundPool.UI_CLICK)


func display_question() -> void:
	current_question = questions[question_index]

	question_label.text = current_question.question
	option_a.text = "A: " + current_question.option_a
	option_b.text = "B: " + current_question.option_b
	option_c.text = "C: " + current_question.option_c
	option_d.text = "D: " + current_question.option_d

func move_to_next_question() -> void:
	if question_index >= num_of_questions -1:
		return
	question_index += 1
	display_question()
	#SoundPool.play_sound(SoundPool.UI_SOMETHING...?)

func on_right_answer() -> void:
	boss_health -= player_damage
	boss_health_bar.value = boss_health
	boss_flash_component._flash()
	SoundPool.play_sound(SoundPool.UI_CORRECT)
	
	if boss_health <= 0:
		on_boss_death()
		#SoundPool.play_sound(SoundPool.BOSS_DEATH)

func on_wrong_question() -> void:
	Events.lose_life.emit()
	player_flash_component._flash()
	shake_camera_2d.add_trauma(randf_range(0.3, 0.5))
	SoundPool.play_sound(SoundPool.UI_WRONG)

	if Globals.Lives <= 0:
		on_player_death()

func on_boss_death() -> void:
	MusicPlayer.stop_track(1.0)
	SoundPool.play_sound(SoundPool.BOSS_DEATH)

func on_player_death() -> void:
	Events.game_over.emit()
	SoundPool.play_sound(SoundPool.MINIGAME_FAIL)
