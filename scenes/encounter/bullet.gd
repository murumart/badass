class_name Bullet extends Node2D

enum {
	TEX_SPARKLE,
	TEX_DROPLET,
	TEX_SPARK,
}

@export var sprite: Sprite2D
@export var sprites: Array[Texture2D]
@export var sprite_index: int

var velocity: Vector2

@export var drag: float = 0
@export var max_lifetime: float = 1.0

var life: float


func _ready() -> void:
	assert(sprite != null and not sprites.is_empty())
	assert(sprite_index < sprites.size())


func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.move_toward(Vector2.ZERO, drag * delta)
	life += delta
	if life > max_lifetime:
		hide()
		set_process(false)
		queue_free()


func set_direction(dir: Vector2, mag: float) -> void:
	velocity = dir * mag


func add_velocity(vec: Vector2) -> void:
	velocity += vec


static func make(pos: Vector2) -> Bullet:
	var b := preload("res://scenes/encounter/bullet.tscn").instantiate() as Bullet
	assert(b != null)

	b.position = pos

	return b
