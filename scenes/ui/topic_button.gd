class_name TopicButton extends Button

enum TopicType {
	IDK,
	GOOD,
	BAD,
}


func display(topic: Topic, progress: int, type: TopicType) -> void:
	text = "> " + topic.name
	show()
