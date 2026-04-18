@abstract class_name BulletSpawner extends Node

@warning_ignore("unused_signal")
signal done

@export var bullet_spawnpoint: Marker2D


@abstract func do(emotion: Topic.Emotion) -> void


func _ready() -> void:
	assert(bullet_spawnpoint != null)


func spawn_circle(centre: Vector2, amt: int, texture: int, wait := 0.01, speed := 180.0) -> void:
	for i in amt:
		var angle := float(i) / (amt / TAU)
		var vec := Vector2.from_angle(angle)
		var bullet := Bullet.make(centre)
		bullet.set_direction(vec, speed)
		bullet.set_texture(texture)
		add_child(bullet)
		await get_tree().create_timer(wait).timeout
