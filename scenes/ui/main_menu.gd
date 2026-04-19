extends Control

@export var play_button: Button
@export var options_button: Button
@export var exit_button: Button


func _ready() -> void:
	options_button.pressed.connect(UI.options.display)

	if OS.has_feature("web"): exit_button.hide()
	exit_button.pressed.connect(get_tree().quit)

	play_button.pressed.connect(func() -> void:
		MGSAnimation.line_index = 0
		UI.swipe_transition(load("res://scenes/mgs_cutscene.tscn"))
	, CONNECT_ONE_SHOT)

	Sounds.play_song("alien_music")
