extends Node2D

enum Mode {
	IDLE,
	SCANNING,
}

@export var scanner: Node2D
@export var scanner_default_position: Marker2D

var mode: Mode


func _ready() -> void:
	assert(scanner != null)
	assert(scanner_default_position != null)
	_reset_scanner()


func start_scanning() -> void:
	mode = Mode.SCANNING


func end_scanning() -> void:
	mode = Mode.IDLE
	_reset_scanner()


func _reset_scanner() -> void:
	scanner.position = scanner_default_position.position


func _process(_delta: float) -> void:
	match mode:
		Mode.IDLE: pass
		Mode.SCANNING:
			var mpos := get_local_mouse_position()
			scanner.position = mpos
