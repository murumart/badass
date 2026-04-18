class_name Console extends Node2D

signal topic_chosen(topic: int)
signal scanning_ended(score: int)

enum Mode {
	IDLE,
	SCANNING,
}

@export var scanner: Node2D
@export var scanner_area: Area2D
@export var scanner_default_position: Marker2D
@export var topic_buttons: Array[TopicButton]
@export var scan_label: Label
@export var device_show: Sprite2D

static var scan_max: int = 0
var scan_caught := 0

var mode: Mode
var _score := 0


func _ready() -> void:
	assert(scanner != null)
	assert(scanner_area != null)
	assert(device_show != null)
	assert(scan_label != null)
	assert(scanner_default_position != null)
	assert(topic_buttons.size() == 4 and not topic_buttons.any(func(b: Button) -> bool: return b == null))
	for i in topic_buttons.size():
		topic_buttons[i].pressed.connect(_topic_chosen.bind(i))
	_reset_scanner()
	_reset_topics()


func start_scanning() -> void:
	device_show.hide()
	scanner.show()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	assert(mode == Mode.IDLE)
	scan_caught = 0
	var tw := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(scanner, "position", get_local_mouse_position(), 0.1)
	await tw.finished
	mode = Mode.SCANNING


func end_scanning() -> void:
	assert(mode == Mode.SCANNING)
	mode = Mode.IDLE
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	var tw := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(scanner, "position", Vector2.ZERO, 0.5)
	tw.tween_interval(1.0)
	tw.tween_property(scanner, "position", scanner_default_position.position, 0.3)
	await tw.finished
	scanning_ended.emit(_score)
	_reset_scanner()


func _reset_scanner() -> void:
	scanner.position = scanner_default_position.position
	scanner.hide()
	device_show.show()
	_score = 0
	scan_max = 0


func _reset_topics() -> void:
	for t in topic_buttons:
		t.hide()


func _process(_delta: float) -> void:
	match mode:
		Mode.IDLE: pass
		Mode.SCANNING:
			var mpos := get_local_mouse_position()
			scanner.position = mpos
			scanner_area.force_update_transform()
			var collided := scanner_area.get_overlapping_areas()
			for a: Bullet in collided:
				a.queue_free()
				scan_caught += 1
				_score = int(float(scan_caught) / scan_max * 100)
				scan_label.text = str(_score) + "%"


func prepare_topics(topics: Array[AbstractTopic], person: Person) -> void:
	assert(topics.size() <= 4)
	assert(topics.size() > 0, "need topics to prepare them,.......")
	_reset_topics()
	for i in topics.size():
		topic_buttons[i].display(topics[i], person, TopicButton.TopicType.IDK)


func _topic_chosen(i: int) -> void:
	topic_chosen.emit(i)
	_reset_topics()
