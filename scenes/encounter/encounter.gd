class_name Encounter extends Node2D

enum Stage {
	WAITING,
	CHOOSING_TOPIC,
	SPEAKING,
	REACTING,
	FINAL_SPEECH,
}

@export var data: EncounterData

@export var background_parent: Node
@export var person_parent: Node
@export var console: Console

var person: Person
var background: Node2D
var stage: Stage


func _ready() -> void:
	stage = Stage.WAITING

	assert(data != null)
	background = data.background.instantiate()
	background_parent.add_child(background)
	person = data.person.instantiate() as Person
	assert(person != null, "person is null (wrong type?)")
	person.speaking_finished.connect(_on_person_spoke)
	person_parent.add_child(person)
	person.modulate.a = 0
	assert(console != null)
	console.topic_chosen.connect(_on_topic_chosen)

	begin_encounter()


func begin_encounter() -> void:
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC)
	tw.tween_interval(1)
	person.play_animation("idle")
	tw.tween_property(person, "modulate:a", 1.0, 1.0).from(0.0)
	tw.tween_interval(1)
	if false and not person.starting_lines.is_empty():
		tw.tween_callback(func() -> void:
			person.speak(person.starting_lines)
		)
	tw.tween_callback(func() -> void:
		prepare_topics()
	)


var _prepared_topics: Array[Topic] = []
func prepare_topics() -> void:
	assert(stage == Stage.WAITING)

	if person.goal_progress >= person.goal:
		stage = Stage.FINAL_SPEECH
		person.speak.call_deferred(person.ending_lines)
		return

	stage = Stage.CHOOSING_TOPIC
	var topics := _get_available_topics()
	topics.shuffle()
	if topics.size() > 4:
		topics = topics.slice(0, 4)
	console.prepare_topics(topics)
	_prepared_topics = topics


func _get_available_topics() -> Array[Topic]:
	var ts: Array[Topic] = []
	for t in person.topics:
		match t.topic_appears_when:
			Topic.PrereqBehaviour.NO_PREREQUISITE: pass
			Topic.PrereqBehaviour.PREREQUISITE_EXHAUSTED:
				var prerec := person.topics[t.prerequisite_topic_index]
				if not person.is_topic_exhausted(prerec):
					continue # don't add this topic
		if person.is_topic_exhausted(t): continue
		ts.append(t)
	assert(not ts.is_empty(), "no topics are available....")
	return ts


func _on_topic_chosen(topic: int) -> void:
	assert(stage == Stage.CHOOSING_TOPIC)
	var t: Topic = _prepared_topics[topic]
	var progress := person.progress_topic_and_get_previous(t)
	stage = Stage.SPEAKING
	person.further_goal(t.contribution_to_goal)
	person.speak(t.responses[progress])


func _on_person_spoke() -> void:
	if stage == Stage.FINAL_SPEECH:
		assert(false, "go to next encopunter here")
	stage = Stage.WAITING
	prepare_topics()


static func enter(tree: SceneTree, edata: EncounterData) -> void:
	var instance := preload("res://scenes/encounter/encounter.tscn").instantiate() as Encounter
	assert(instance != null)
	instance.data = edata
	tree.change_scene_to_node(instance)
