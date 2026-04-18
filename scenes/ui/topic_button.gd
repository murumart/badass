class_name TopicButton extends Button

enum TopicType {
	IDK,
	GOOD,
	BAD,
}


func display(topic: AbstractTopic, _progress: int, _type: TopicType) -> void:
	text = "> " + topic.name
	show()
