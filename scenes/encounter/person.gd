class_name Person extends Node2D

enum Mode {
	IDLE,
	SEND_SIGNAL,
}

@export_group("Internal")
@export var mode: Mode
@export_group("")


func _ready() -> void:
	pass
