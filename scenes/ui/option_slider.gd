class_name OptionSlider extends HBoxContainer

signal option_change_gotten(to: float)

@onready var label: Label = $Label
@onready var slider: HSlider = $HSlider

var _set_value: Callable


func _ready() -> void:
	slider.value_changed.connect(_on_value_changed)


func _on_value_changed(f: float) -> void:
	option_change_gotten.emit(f)
	assert(_set_value.is_valid())
	_set_value.call(f)


func display(
	option_name: StringName,
	get_value: Callable,
	set_value: Callable,
	range_min: float = 0.0,
	range_max: float = 1.0
) -> void:
	label.text = option_name.capitalize()
	slider.min_value = range_min
	slider.max_value = range_max

	slider.set_value_no_signal(get_value.call())
	_set_value = set_value


static func get_instance() -> OptionSlider:
	return preload("res://scenes/ui/option_slider.tscn").instantiate()
