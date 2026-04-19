class_name Encounter extends Node2D

enum Stage {
	WAITING,
	CHOOSING_TOPIC,
	REACTING,
	SPEAKING,
	FINAL_SPEECH,
}

@export var data: EncounterData

@export var background_parent: Node
@export var person_parent: Node
@export var console: Console

@export var good_convo_topic: Label

@onready var scanning_good_sound: AudioStreamPlayer = %ScanningGoodSound

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
	assert(good_convo_topic != null)
	good_convo_topic.hide()

	display_score()
	begin_encounter()


func begin_encounter() -> void:
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC)
	tw.tween_interval(data.delay_before_begin_s)
	if not data.person_enter_animation:
		person.play_animation("idle")
		tw.tween_property(person, "modulate:a", 1.0, 1.0).from(0.0)
		tw.tween_interval(1)
	else:
		person.modulate.a = 1
		person.animator.play(data.person_enter_animation)
		person.animator.queue("idle")
		tw.tween_interval(person.animator.get_animation(data.person_enter_animation).length)
	if not person.starting_lines.is_empty():
		tw.tween_callback(func() -> void:
			person.speak(person.starting_lines)
		)
	else:
		tw.tween_callback(func() -> void:
			prepare_topics()
		)


var _prepared_topics: Array[AbstractTopic] = []
func prepare_topics() -> void:
	assert(stage == Stage.WAITING)

	stage = Stage.CHOOSING_TOPIC
	var topics := _get_available_topics()
	topics.shuffle()
	if topics.size() > 3:
		topics = topics.slice(0, 3)
	topics.append(person.goal_topic)
	assert(not topics.is_empty(), "no topics are available....")
	console.prepare_topics(topics, person)
	_prepared_topics = topics


func _get_available_topics() -> Array[AbstractTopic]:
	if person.goal_progress >= person.goal:
		return [] # goaltopic get added in prepare_topics
	var ts: Array[AbstractTopic] = []
	for t in person.topics:
		match t.topic_appears_when:
			Topic.PrereqBehaviour.NO_PREREQUISITE: pass
			Topic.PrereqBehaviour.PREREQUISITE_EXHAUSTED:
				var prerec := person.topics[t.prerequisite_topic_index]
				if not person.is_topic_exhausted(prerec):
					continue # don't add this topic
		if person.is_topic_exhausted(t): continue
		ts.append(t)
	return ts


var _notified := {}

func _on_topic_chosen(topic: int) -> void:
	assert(stage == Stage.CHOOSING_TOPIC)
	var t: AbstractTopic = _prepared_topics[topic]
	var progress := person.progress_topic_and_get_previous(t)

	if t is GoalTopic:
		stage = Stage.FINAL_SPEECH
		if person.goal_progress >= person.goal:
			person.speak.call_deferred(t.win_text)
			await person.speaking_finished
			person.speak.call_deferred(person.ending_lines)
			await person.speaking_finished
			_next_encounter()
		else:
			person.speak.call_deferred(t.lose_text)
			await person.speaking_finished
			_gameover()
		return

	var score := 0
	if t.emotional_response != Topic.Emotion.NONE:
		var tw := create_tween().set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(background_parent, "modulate", Color.DARK_SLATE_GRAY, 1.0)
		person.respond_to_topic(t.emotional_response)
		console.start_scanning()

		stage = Stage.REACTING

		await person.emoting_finished
		console.end_scanning()
		score = await console.scanning_ended
		tw = create_tween().set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(background_parent, "modulate", Color.WHITE, 1.0)

	stage = Stage.SPEAKING
	person.further_goal(t.contribution_to_goal + person.get_topic_knowledge(t) * 0.01)
	person.further_topic_knowledge(t, score + int(person.get_topic_knowledge(t) * 0.05))
	if person.get_topic_knowledge(t) >= 50 and t not in _notified and t is Topic:
		_notified[t] = true
		good_convo_topic.show()
		var good := (t as Topic).contribution_to_goal > 0
		if good:
			scanning_good_sound.play()
		var bad := (t as Topic).contribution_to_goal < 0
		good_convo_topic.text = t.name + " is a " + ("good" if good else "bad" if bad else "useless") + " convo topic!"
		var colors: PackedColorArray = (
			[Color.YELLOW, Color.GREEN] if good
			else [Color.RED, Color.WHITE] if bad
			else [Color.ALICE_BLUE, Color.GRAY]
		)
		var tw := create_tween().set_trans(Tween.TRANS_EXPO)
		for i in 20:
			tw.tween_property(good_convo_topic, ^"modulate", colors[0], 0.1)
			tw.tween_property(good_convo_topic, ^"modulate", colors[1], 0.1)
		tw.tween_callback(good_convo_topic.hide)
	elif t not in _notified and t is Topic:
		good_convo_topic.modulate = Color.WHITE
		good_convo_topic.text = "didn't get enough information..."
		good_convo_topic.show()
		var tw := create_tween().set_trans(Tween.TRANS_EXPO)
		tw.tween_interval(4)
		tw.tween_callback(good_convo_topic.hide)
	person.speak(t.responses[progress])
	display_score()


func display_score() -> void:
	console.display_score(person.goal_progress / person.goal)


func _on_person_spoke() -> void:
	person.play_animation("idle")
	if stage == Stage.FINAL_SPEECH:
		if person.goal_progress <= 0:
			_gameover()
		return
	if person.goal_progress <= 0:
		stage = Stage.FINAL_SPEECH
		person.speak.call_deferred(person.ending_fail_lines)
		return
	stage = Stage.WAITING
	prepare_topics()


func _next_encounter() -> void:
	data.next.go()


func _gameover() -> void:
	Cutscene.last_encounter = data
	UI.swipe_transition(load("res://scenes/Cutscenes/men_in_black.tscn"))


static func enter(edata: EncounterData) -> void:
	var instance := preload("res://scenes/encounter/encounter.tscn").instantiate() as Encounter
	assert(instance != null)
	instance.data = edata
	UI.swipe_transition_n(instance)
