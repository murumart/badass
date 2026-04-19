class_name Cutscene extends Node2D

signal finished

@export var next: NextScene


func finish() -> void:
	finished.emit()
	next.go()
