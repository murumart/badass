class_name Cutscene extends Node2D

signal finished

@export var next_encounter: EncounterData


func finish() -> void:
	finished.emit()
	Encounter.enter(next_encounter)
