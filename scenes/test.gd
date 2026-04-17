class_name Test
extends Node2D

const Coolsprite = preload("res://scenes/coolsprite.gd")

var arr: Array[Node] = []
var dict := {}

@export var muna: RigidBody2D
@export var muna2: RigidBody2D
@export var muu: Sprite2D
@export_range(0, 10,0.01) var thing: float

func _ready() -> void:
	assert(muna != null)
	assert(muna2 != null)
	assert(muu != null)
	muna.body_entered.connect(func(n: Node) -> void:
		var n2d := n as Node2D
		assert(n2d != null)
		n2d.position.y += 5
	)
	muna2.contact_monitor = true
	muna2.max_contacts_reported = 20

	muna2.body_entered.connect(func(_n: Node) -> void:
		muna2.queue_free()
		print("peale collisionit queued for deletion: ", muna2.is_queued_for_deletion())
	)
	if is_instance_valid(muna2):
		print("kohe valiidne")
	print("queued for deletion: ", muna2.is_queued_for_deletion())
	(func() -> void:
		if is_instance_valid(muna2):
			print("deferred callis valiidne")
		else:
			print("deferred callis ei ole valiidne.")).call_deferred()
	await get_tree().process_frame
	if is_instance_valid(muna2):
		print("peale awaiti valiidne")
	else:
		print("peale awaiti ei ole valiidne.")


func askdasda(beeb: int, cee := false) -> bool:
	return true


func _process(delta: float) -> void:
	muu.position.x += delta * 60
