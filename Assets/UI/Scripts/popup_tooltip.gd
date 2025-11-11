extends Control
func _input(event: InputEvent) -> void:
	if not visible or not (event is InputEventMouseMotion):
		return

	var mouse_pos = get_global_mouse_position()
	var viewport_size = get_viewport_rect().size
	var tooltip_size = size

	# Default: place tooltip above the cursor (your -316 offset)
	var pos = mouse_pos + Vector2(16, -316)

	# # --- Vertical adjustments ---
	if pos.y < 4:
		pos.y = mouse_pos.y + 16   # flip below cursor if no room above


	# --- Horizontal adjustments ---
	if pos.x + tooltip_size.x > viewport_size.x - 300:
		pos.x = mouse_pos.x - tooltip_size.x - 316  # flip to left if too far right


	global_position = pos
