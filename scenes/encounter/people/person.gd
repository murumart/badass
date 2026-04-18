class_name Person extends Node2D

enum Mode {
	IDLE,
	SEND_SIGNAL,
}

@export var topics: Array[Topic]
@export_range(1.0, 10.0, 0.05) var goal: float
@export_multiline var starting_lines: String

@export_group("Internal")
@export var animator: AnimationPlayer
@export var mode: Mode
@export_group("")

var topic_progresses: Dictionary[Topic, int]


func _ready() -> void:
	assert(animator != null, "person needs an animator to be animated.")


func play_animation(anim: StringName) -> void:
	assert(animator.has_animation(anim))
	animator.play("anim")
	animator.queue("idle")
