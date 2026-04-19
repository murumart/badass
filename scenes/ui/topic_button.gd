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
		if person.goal_progress >= person.goal:
			text = text + " (TRUSTED)"
		else:
			text = text + " (need trust)"
	elif know < 50:
		text += " (...?%s%%)" % know
	elif topic is Topic:
		if (topic.contribution_to_goal > 0):
			text += " GOOD (+%s)" % int(topic.contribution_to_goal * 100)
		else:
			text += "BAD (%s)" % int(topic.contribution_to_goal * 100)
	show()
