@abstract class_name AbstractTopic extends Resource

enum Emotion {
	NONE,
	HAPPY,
	ANGRY,
	SURPRISED,
	NERVOUS,
	SAD,
	SMUG,
}

enum PrereqBehaviour {
	NO_PREREQUISITE,
	PREREQUISITE_EXHAUSTED,
}

@export var name: String
