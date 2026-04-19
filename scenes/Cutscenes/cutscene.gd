class_name Cutscene extends Node2D

signal finished

static var last_encounter: EncounterData # MASSIVE HACK

@export var next: NextScene


func finish() -> void:
	finished.emit()
	next.go()
