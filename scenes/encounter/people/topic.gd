class_name Topic extends AbstractTopic

@export_multiline var responses: PackedStringArray
@export var emotional_response: Emotion
@export_range(-1, 1, 0.05, "or_less", "or_greater") var contribution_to_goal: float = 0.0
@export var topic_appears_when: PrereqBehaviour
@export_group("Prerequisites")
@export_range(0, 10) var prerequisite_topic_index: int = -1
