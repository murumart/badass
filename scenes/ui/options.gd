class_name OptionsMenu extends PanelContainer

static var _options := {
	"sound": {
		"main_volume": {
			"setv": func(to: float) -> void:
				assert(to >= 0.0 and to <= 1.0, "volume out of range")
				AudioServer.set_bus_volume_linear(0, to),
			"getv": func() -> float:
				return AudioServer.get_bus_volume_linear(0),
			"default": 0.75,
		}
	}
}

@export var list: Container

var is_open := false


func _ready() -> void:
	assert(list != null)


func display() -> void:
	list.get_children().map(func(n: Node) -> void: n.queue_free())
	load_from_file()
	for catk: String in _options.keys():

		var catlbl := Label.new()
		catlbl.text = catk.capitalize()
		list.add_child(catlbl)

		var catv: Dictionary = _options[catk]
		for opk: String in catv.keys():
			var opv: Dictionary = catv[opk]
			var slider := OptionSlider.get_instance()
			list.add_child(slider)
			slider.display(opk, opv["getv"], opv["setv"], opv.get("range", Vector2(0, 1)).x, opv.get("range", Vector2(0, 1)).y)

	show.call_deferred()
	set_deferred("is_open", true)


func close() -> void:
	save_to_file()
	hide.call_deferred()
	set_deferred("is_open", false)


const OPTIONS_PATH := "user://options.cfg"

func save_to_file() -> void:
	var cfgfile := ConfigFile.new()
	for catk: String in _options.keys():
		for opk: String in _options[catk]:
			assert("getv" in _options[catk][opk])
			cfgfile.set_value(catk, opk, _options[catk][opk]["getv"].call())
	cfgfile.save(OPTIONS_PATH)


func load_from_file() -> void:
	var cfgfile := ConfigFile.new()
	if FileAccess.file_exists(OPTIONS_PATH):
		cfgfile.load(OPTIONS_PATH)
	for catk: String in _options.keys():
		for opk: String in _options[catk]:
			assert("setv" in _options[catk][opk])
			_options[catk][opk]["setv"].call(cfgfile.get_value(catk, opk, _options[catk][opk].get("default", 1.0)))
