class_name MGSAnimation extends Node2D

@onready var animation: AnimationPlayer = $Animation
@onready var speech_bubble: SpeechBubble = $SpeechBubble

@export_multiline var lines: PackedStringArray
@export var encounters: Array[EncounterData]
static var line_index := 0


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	animation.play(&"pop_in")
	await animation.animation_finished
	speech_bubble.speak_lines(lines[line_index].split("\n"))
	speech_bubble.line_finished.connect(func() -> void:
		speech_bubble.line_began.connect(func() -> void:
			animation.play(&"pop_alian_in")
		, CONNECT_ONE_SHOT)
	, CONNECT_ONE_SHOT)
	await speech_bubble.speaking_finished
	await get_tree().create_timer(0.1).timeout
	animation.play_backwards(&"pop_in")
	await animation.animation_finished
	Encounter.enter(encounters[line_index])
