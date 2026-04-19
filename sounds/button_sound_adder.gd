class_name ButtonSoundAdder extends Node


func _recurse(nod: Node, buttons: Array[Button]) -> void:
	for n in nod.get_children():
		if n is Button:
			buttons.append(n)
		_recurse(n, buttons)


func _ready() -> void:
	var buttons: Array[Button]
	_recurse(get_parent(), buttons)
	#print(buttons)
	var sd := {"volume": -14.0}
	for b in buttons:
		b.mouse_entered.connect(func() -> void:
			if b.is_visible_in_tree() and not b.disabled:
				Sounds.play_sound(preload("res://sounds/blip.ogg"), sd)
		)
		b.pressed.connect(Sounds.play_sound.bind(preload("res://sounds/bleep.ogg"), sd))
