class_name Encounter extends Node2D

@export var data: EncounterData

@export var background_parent: Node
@export var person_parent: Node


func _ready() -> void:
	assert(data != null)
	background_parent.add_child(data.background.instantiate())
	person_parent.add_child(data.person.instantiate())


static func enter(tree: SceneTree, edata: EncounterData) -> void:
	var instance := preload("res://scenes/encounter/encounter.tscn").instantiate() as Encounter
	assert(instance != null)
	instance.data = edata
	tree.change_scene_to_node(instance)
