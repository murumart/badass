class_name Person extends Node2D

enum Mode {
	IDLE,
	SEND_SIGNAL,
}

@export var animator: AnimationPlayer

@export_group("Internal")
@export var mode: Mode
@export_group("")


func _ready() -> void:
	assert(animator != null, "person needs an animator to be animated.")


func play_animation(anim: StringName) -> void:
	assert(animator.has_animation(anim))
	animator.play("anim")
	animator.queue("idle")
