class_name Knight
extends BaseUnit

func attack():
	# Add a small lunge forward during attack
	if not target: return
	var dir = (target.global_position - global_position).normalized()
	position += dir * 8
	await super.attack()
	position -= dir * 8
