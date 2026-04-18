class_name Topic extends Resource

enum Emotion {
	NONE,
	HAPPY,
	ANGRY,
	SURPRISED,
	NERVOUS,
	SAD,
}

enum PrereqBehaviour {
	NO_PREREQUISITE,
	PREREQUISITE_EXHAUSTED,
}

@export var name: String
@export_multiline var responses: PackedStringArray
@export var emotional_response: Emotion
@export_range(-1, 1, 0.05, "or_less", "or_greater") var contribution_to_goal: float = 0.0
@export var topic_appears_when: PrereqBehaviour
@export_group("Prerequisites")
@export_range(0, 10) var prerequisite_topic_index: int = -1
