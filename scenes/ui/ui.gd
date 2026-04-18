extends CanvasLayer

@export var options: OptionsMenu


func _ready() -> void:
	assert(options != null)
	options.load_from_file()
	options.close()


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	assert(k != null)
	if k.keycode == KEY_ESCAPE and k.pressed:
		if options.open:
			options.close()
		else:
			options.display()
