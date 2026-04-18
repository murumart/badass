class_name Console extends Node2D

signal topic_chosen(topic: String)

enum Mode {
	IDLE,
	SCANNING,
}

@export var scanner: Node2D
@export var scanner_default_position: Marker2D
@export var topic_buttons: Array[Button]

var mode: Mode


func _ready() -> void:
	assert(scanner != null)
	assert(scanner_default_position != null)
	assert(topic_buttons.size() == 4 and not topic_buttons.any(func(b: Button) -> bool: return b == null))
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


func prepare_topics(topics: PackedStringArray) -> void:
	assert(topics.size() <= 4)
	assert(topics.size() > 0, "need topics to prepare them,.......")
	for t in topic_buttons:
		t.hide()
	for i in topics.size():
		topic_buttons[i].text = topics[i]
		topic_buttons[i].show()
		topic_buttons[i].pressed.connect(_topic_chosen.bind(topics[i]), CONNECT_ONE_SHOT)


func _topic_chosen(s: String) -> void:
	for t in topic_buttons:
		t.hide()
	topic_chosen.emit(s)
