extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	await get_tree().create_timer(0.2).timeout
	
	get_tree().change_scene_to_file("res://scenes/test_screen.tscn")
