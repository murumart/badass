class_name SpeechBubble extends PanelContainer

signal _next_line_requested
signal line_finished
signal speaking_finished

enum State {
	IDLE,
	SPEAKING,
}

var state: State

@export var textlabel: RichTextLabel
@export var nextbutton: Button

var _remove_bbcode_regex := RegEx.new()


func _ready() -> void:
	assert(textlabel != null)
	assert(nextbutton != null)
	hide()
	_remove_bbcode_regex.compile("\\[.+?\\]")
	nextbutton.pressed.connect(request_next_line)
	nextbutton.hide()


func speak_lines(lines: PackedStringArray) -> void:
	assert(state == State.IDLE)
	show()
	state = State.SPEAKING
	for line in lines:
		speak_text(line)
		await line_finished
		nextbutton.show()
		await _next_line_requested
		nextbutton.hide()
	state = State.IDLE
	speaking_finished.emit()
	hide()


func speak_text(text: String) -> void:
	assert(state == State.SPEAKING)
	state = State.SPEAKING
	textlabel.text = text
	textlabel.visible_ratio = 0.0
	var tw := create_tween()
	var stripped := _remove_bbcode_regex.sub(text, "", true)
	tw.tween_property(textlabel, ^"visible_ratio", 1.0, stripped.length() * 0.03)
	tw.tween_callback(func() -> void:
		line_finished.emit()
	)


func request_next_line() -> void:
	_next_line_requested.emit()
