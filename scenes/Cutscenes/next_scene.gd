class_name NextScene extends Resource

@export var next_encounter: EncounterData
@export var mgs_cutscene_index := 0
@export_file_path("*.tscn") var next_scene_path: String


func go() -> void:
	if next_scene_path:
		MGSAnimation.line_index = mgs_cutscene_index # WARNING HACK
		UI.swipe_transition(load(next_scene_path))
	elif next_encounter != null:
		Encounter.enter(next_encounter)
