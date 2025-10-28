class_name Pirate
extends BaseUnit

func attack():
	# Slightly slower attack animation
	await get_tree().create_timer(0.5).timeout
	await super.attack()
