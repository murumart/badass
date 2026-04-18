extends CanvasLayer

@export var options: OptionsMenu
@export var swipe_animation: AnimationPlayer

var _transitioning: bool
var transitioning: bool:
	get:
		return _transitioning
	set(to):
		assert(false)


func _ready() -> void:
	assert(options != null)
	assert(swipe_animation != null)
	options.load_from_file()
	options.close()


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	assert(k != null)
	if k.keycode == KEY_ESCAPE and k.pressed:
		if options.is_open:
			options.close()
		elif false:
			options.display()


func swipe_transition_n(n: Node) -> void:
	assert(not _transitioning, "don't start transitioning while already transitioning")
	_transitioning = true
	var root := get_tree().root
	var current := root.get_child(-1)

	swipe_animation.play("swipe_in")
	await swipe_animation.animation_finished
	root.remove_child(current)
	current.queue_free()

	root.add_child(n)
	get_tree().current_scene = n
	swipe_animation.play("swipe_out")
	await swipe_animation.animation_finished
	_transitioning = false


func swipe_transition(to: PackedScene) -> void:
	swipe_transition_n(to.instantiate())
