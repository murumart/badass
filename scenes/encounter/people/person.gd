class_name Person extends Node2D

signal emoting_finished
signal speaking_finished

enum State {
	IDLE,
	SENDING_SIGNAL,
	SPEAKING,
}

@export var topics: Array[AbstractTopic]
@export var goal_topic: GoalTopic
@export_range(1.0, 10.0, 0.05) var goal: float
@export_multiline var starting_lines: String
@export_multiline var ending_lines: String
@export_multiline var ending_fail_lines: String
@export var emotion_response_animations: Dictionary[Topic.Emotion, StringName]

@export_group("Internal")
@export var speech_bubble: SpeechBubble
@export var animator: AnimationPlayer
@export var bullet_spawner: BulletSpawner
@export_group("")

var _state: State
var state: State:
	get:
		return _state
	set(value):
		var old := _state
		_state = value
		_on_state_set(value, old)

var topic_progresses: Dictionary[AbstractTopic, int]
var topic_knowledges: Dictionary[AbstractTopic, int]
var goal_progress: float = 0.0


func _ready() -> void:
	assert(animator != null, "person needs an animator to be animated.")
	assert(animator.has_animation("idle"), "animator needs idle animation")
	assert(speech_bubble != null)
	assert(ending_fail_lines != "", "person needs ending fail lines to end encounter with")
	assert(bullet_spawner != null, "person needs internal bullet spawner to be set")
	_validate_topics() # TODO uncomment when the logic is implemented

	state = State.IDLE


func play_animation(anim: StringName) -> void:
	assert(animator.has_animation(anim))
	animator.play(anim)


func speak(text: String) -> void:
	assert(state == State.IDLE)
	var lines := text.split("\n")
	state = State.SPEAKING
	speech_bubble.speak_lines(lines)
	await speech_bubble.speaking_finished
	state = State.IDLE
	speaking_finished.emit()


func get_topic_progress(topic: AbstractTopic) -> int:
	return topic_progresses.get(topic, 0)


func is_topic_exhausted(topic: AbstractTopic) -> bool:
	return get_topic_progress(topic) == topic.responses.size()


func progress_topic_and_get_previous(topic: AbstractTopic) -> int:
	var p: int = topic_progresses.get(topic, 0)
	topic_progresses[topic] = p + 1
	return p


func further_goal(progress: float) -> void:
	goal_progress += progress


func further_topic_knowledge(topic: AbstractTopic, amount: int) -> void:
	topic_knowledges[topic] = mini(topic_knowledges.get(topic, 0) + amount, 100)


func get_topic_knowledge(topic: AbstractTopic) -> int:
	return topic_knowledges.get(topic, 0)


func _on_state_set(_to: State, _old: State) -> void:
	pass


func respond_to_topic(emotion: Topic.Emotion) -> void:
	assert(emotion != Topic.Emotion.NONE)
	if emotion in emotion_response_animations:
		play_animation(emotion_response_animations[emotion])
	bullet_spawner.do(emotion)
	await bullet_spawner.done
	await get_tree().create_timer(1.0).timeout
	match emotion:
		Topic.Emotion.SURPRISED:
			pass
	emoting_finished.emit()


func _validate_topics() -> void:
	var i := 0
	var found := []
	assert(goal_topic != null)
	var alltopics := topics + [goal_topic]
	for topic: AbstractTopic in alltopics:
		assert(topic != null, "null topic no good")
		assert(topic.name not in found, "topic name used already")
		assert(topic.name != "", "topic name is empty")
		if topic is Topic: assert(not topic.responses.is_empty(), "topic has no text responses")
		found.append(topic.name)
		if topic is Topic: if topic.topic_appears_when == Topic.PrereqBehaviour.PREREQUISITE_EXHAUSTED:
			assert(topic.prerequisite_topic_index != i, "topic's prerequisite index is itself's index")
			assert(topic.prerequisite_topic_index >= 0 and topic.prerequisite_topic_index < topics.size(), "topic's prerequisite index out of range")
		i += 1
