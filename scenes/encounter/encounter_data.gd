class_name EncounterData extends Resource

@export var person: PackedScene
@export var background: PackedScene
@export var delay_before_begin_s: float = 1.0
@export var person_enter_animation: StringName
@export var next: NextScene
@export var music: StringName = &"alien_music"
@export_file_path("*.tscn") var gameover_scene_path := "res://scenes/Cutscenes/men_in_black.tscn"
