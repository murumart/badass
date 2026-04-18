class_name Encounter extends Node2D

@export var data: EncounterData

@export var background_parent: Node
@export var person_parent: Node

var person: Person
var background: Node2D


func _ready() -> void:
	assert(data != null)
	background = data.background.instantiate()
	background_parent.add_child(background)
	person = data.person.instantiate() as Person
	assert(person != null, "person is null (wrong type?)")
	person_parent.add_child(person)
	person.modulate.a = 0

	begin_encounter()


func begin_encounter() -> void:
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC)
	tw.tween_interval(1)
	person.play_animation("idle")
	tw.tween_property(person, "modulate:a", 1.0, 1.0).from(0.0)
	tw.tween_interval(1)
	if not person.starting_lines.is_empty():
		tw.tween_callback(func() -> void:
			person.speak(person.starting_lines)
		)


static func enter(tree: SceneTree, edata: EncounterData) -> void:
	var instance := preload("res://scenes/encounter/encounter.tscn").instantiate() as Encounter
	assert(instance != null)
	instance.data = edata
	tree.change_scene_to_node(instance)
