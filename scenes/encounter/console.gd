class_name Console extends Node2D

signal topic_chosen(topic: int)

enum Mode {
	IDLE,
	SCANNING,
}

@export var scanner: Node2D
@export var scanner_default_position: Marker2D
@export var topic_buttons: Array[TopicButton]

var mode: Mode


func _ready() -> void:
	assert(scanner != null)
	assert(scanner_default_position != null)
	assert(topic_buttons.size() == 4 and not topic_buttons.any(func(b: Button) -> bool: return b == null))
	for i in topic_buttons.size():
		topic_buttons[i].pressed.connect(_topic_chosen.bind(i))
	_reset_scanner()
	_reset_topics()


func start_scanning() -> void:
	assert(mode == Mode.IDLE)
	mode = Mode.SCANNING


func end_scanning() -> void:
	assert(mode == Mode.SCANNING)
	mode = Mode.IDLE
	var tw := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(scanner, "position", scanner_default_position.position, 0.6)
	await tw.finished
	_reset_scanner()


func _reset_scanner() -> void:
	scanner.position = scanner_default_position.position


func _reset_topics() -> void:
	for t in topic_buttons:
		t.hide()


func _process(_delta: float) -> void:
	match mode:
		Mode.IDLE: pass
		Mode.SCANNING:
			var mpos := get_local_mouse_position()
			scanner.position = mpos


func prepare_topics(topics: Array[AbstractTopic], topic_progresses: Dictionary[AbstractTopic, int]) -> void:
	assert(topics.size() <= 4)
	assert(topics.size() > 0, "need topics to prepare them,.......")
	_reset_topics()
	for i in topics.size():
		topic_buttons[i].display(topics[i], topic_progresses.get(topics[i], 0), TopicButton.TopicType.IDK)
		topic_buttons[i].show()


func _topic_chosen(i: int) -> void:
	topic_chosen.emit(i)
	_reset_topics()
