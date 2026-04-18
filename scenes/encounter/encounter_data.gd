class_name EncounterData extends Resource

@export var person: PackedScene
@export var background: PackedScene
@export var delay_before_begin_s: float = 1.0
@export var person_enter_animation: StringName
@export var next_encounter: EncounterData
@export var mgs_cutscene_index := 0
@export_file_path("*.tscn") var next_scene_path: String
