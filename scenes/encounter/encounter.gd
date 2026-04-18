class_name Encounter extends Node2D

@export var data: EncounterData

@export var background_parent: Node
@export var person_parent: Node
@export var console: Console

var person: Person
var background: Node2D


func _ready() -> void:
	assert(data != null)
	background = data.background.instantiate()
	background_parent.add_child(background)
	person = data.person.instantiate() as Person
	assert(person != null, "person is null (wrong type?)")
	person_parent.add_child(person)
	person.modulate.a = 0

	begin_encounter()


func begin_encounter() -> void:
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC)
	tw.tween_interval(1)
	person.play_animation("idle")
	tw.tween_property(person, "modulate:a", 1.0, 1.0).from(0.0)
	tw.tween_interval(1)
	if not person.starting_lines.is_empty():
		tw.tween_callback(func() -> void:
			person.speak(person.starting_lines)
		)
	tw.tween_callback(func() -> void:
		var topics := _get_available_topics()
		topics.shuffle()
		if topics.size() > 4:
			topics = topics.slice(0, 4)
		console.prepare_topics(topics)
	)


func _get_available_topics() -> Array[String]:
	var ts: Array[String] = []
	for t in person.topics:
		match t.topic_appears_when:
			Topic.PrereqBehaviour.NO_PREREQUISITE: pass
			Topic.PrereqBehaviour.PREREQUISITE_EXHAUSTED:
				var prerec := person.topics[t.prerequisite_topic_index]
				if not person.is_topic_exhausted(prerec):
					continue # don't add this topic
		if person.is_topic_exhausted(t): continue
		ts.append(t.name)
	assert(not ts.is_empty(), "no topics are available....")
	return ts


func _on_topic_chosen(topic: String) -> void:
	for t in person.topics:
		if t.name != topic: continue
		person.progress_topic(t)
		return
	assert(false, "don't have this topic at all.")


static func enter(tree: SceneTree, edata: EncounterData) -> void:
	var instance := preload("res://scenes/encounter/encounter.tscn").instantiate() as Encounter
	assert(instance != null)
	instance.data = edata
	tree.change_scene_to_node(instance)
