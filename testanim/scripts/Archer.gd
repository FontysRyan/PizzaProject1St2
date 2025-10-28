class_name Archer
extends BaseUnit

@export var arrow_scene := preload("res://testanim/Arrow.tscn")

func spawn_arrow(target_pos: Vector2):
	var arrow = arrow_scene.instantiate()
	arrow.position = global_position
	arrow.direction = (target_pos - global_position).normalized()
	arrow.target = target
	get_tree().current_scene.add_child(arrow)
	
func attack():
	if not target or not can_attack or is_dead:
		return
	can_attack = false
	play_state(State.ATTACK)
	emit_signal("attack_started", self)

	await get_tree().create_timer(0.4).timeout  # Arrow release timing
	spawn_arrow(target.global_position)

	await sprite.animation_finished
	can_attack = true
	play_state(State.IDLE)
	emit_signal("attack_finished", self)
