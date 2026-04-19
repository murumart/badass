class_name TopicButton extends Button

enum TopicType {
	IDK,
	GOOD,
	BAD,
}


func display(topic: AbstractTopic, person: Person, _type: TopicType) -> void:
	text = "> " + topic.name
	var know := person.get_topic_knowledge(topic)
	if topic is GoalTopic:
		text = "GOAL: " + text
	elif know < 50:
		text += " (...?%s%%)" % know
	elif topic is Topic:
		text += " GOOD (+%s)" % int(topic.contribution_to_goal*100)
	show()
