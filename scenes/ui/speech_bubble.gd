class_name SpeechBubble extends PanelContainer

signal _next_line_requested
signal line_finished
signal line_began
signal speaking_finished

enum State {
	IDLE,
	SPEAKING,
}

var state: State

@export var textlabel: RichTextLabel
@export var nextbutton: Button
@export var skipbutton: Button

var _remove_bbcode_regex := RegEx.new()


func _ready() -> void:
	assert(textlabel != null)
	assert(nextbutton != null)
	assert(skipbutton != null)
	hide()
	_remove_bbcode_regex.compile("\\[.+?\\]")
	nextbutton.pressed.connect(request_next_line)
	skipbutton.pressed.connect(_on_skip_pressed)
	nextbutton.hide()
	skipbutton.hide()


func speak_lines(lines: PackedStringArray) -> void:
	assert(state == State.IDLE)
	show()
	state = State.SPEAKING
	for line in lines:
		speak_text(line)
		await line_finished
		skipbutton.hide()
		nextbutton.show()
		await _next_line_requested
		nextbutton.hide()
	state = State.IDLE
	speaking_finished.emit()
	hide()


var speaker_tween: Tween
func speak_text(text: String) -> void:
	assert(state == State.SPEAKING)
	assert(text != "", "don't spea empty text")
	skipbutton.show()
	state = State.SPEAKING
	textlabel.text = text
	textlabel.visible_ratio = 0.0
	line_began.emit()
	speaker_tween = create_tween()
	var stripped := _remove_bbcode_regex.sub(text, "", true)
	speaker_tween.tween_property(textlabel, ^"visible_ratio", 1.0, stripped.length() * 0.03)
	speaker_tween.tween_callback(func() -> void:
		line_finished.emit()
	)


func _on_skip_pressed() -> void:
	assert(state == State.SPEAKING)
	speaker_tween.kill()
	textlabel.visible_ratio = 1.0
	line_finished.emit()
	skipbutton.hide()


func request_next_line() -> void:
	_next_line_requested.emit()
