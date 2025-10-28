extends Node2D
class_name Arrow

@export var speed := 300.0
var direction := Vector2.ZERO
var target: BaseUnit

func _process(delta):
	if direction == Vector2.ZERO:
		return

	position += direction * speed * delta

	if target and position.distance_to(target.position) < 8:
		target.take_hit(10)
		queue_free()
