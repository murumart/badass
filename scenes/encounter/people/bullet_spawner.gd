@abstract class_name BulletSpawner extends Node

@warning_ignore("unused_signal")
signal done

@abstract func do(emotion: Topic.Emotion) -> void


func wait_t(amt: float) -> void:
	await get_tree().create_timer(amt).timeout


static func rand2() -> float:
	return 1.0 - randf() * 2.0


func spawn_circle(centre: Vector2, amt: int, texture: int, wait := 0.01, speed := 180.0) -> void:
	for i in amt:
		var angle := float(i) / (amt / TAU)
		var vec := Vector2.from_angle(angle)
		var bullet := Bullet.make(centre)
		bullet.set_direction(vec, speed)
		bullet.set_texture(texture)
		add_child(bullet)
		await wait_t(wait)


func spawn_crazy_shape(rnge := 63) -> void:
	Console.scan_max = int(rnge * 2 * 0.8)
	for tt: int in range(-rnge, rnge):
		var t := tt * 0.05
		var b := Bullet.make(Vector2(sin(2 * t) + 3 * sin(t), 2 * sin(3 * t)) * 100)
		b.set_direction(Vector2.DOWN.rotated(remap(tt, -63, 63, 0, TAU)), 0.001)
		b.drag = -90.0
		b.max_lifetime = 2.0
		add_child(b)
		await wait_t(0.01)
