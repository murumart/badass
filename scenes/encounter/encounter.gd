class_name Encounter extends Node2D

@export var data: EncounterData


func _ready() -> void:
	assert(data != null)


static func enter(tree: SceneTree, edata: EncounterData) -> void:
	var instance := preload("res://scenes/encounter/encounter.tscn").instantiate() as Encounter
	assert(instance != null)
	instance.data = edata
	tree.change_scene_to_node(instance)
