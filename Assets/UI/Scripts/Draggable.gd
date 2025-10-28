extends Control

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_parent: Node = null
var original_position: Vector2 = Vector2.ZERO

# Mark if the piece is in the shop (cannot swap while in shop)
var in_shop: bool = true

# Enable swapping behavior when dropping onto an occupied grid cell
const ALLOW_SWAP: bool = true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(event)
		else:
			_stop_drag(event)

func _process(_delta: float) -> void:
	if dragging:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		global_position = mouse_pos - drag_offset

func _start_drag(event: InputEventMouseButton) -> void:
	dragging = true
	original_parent = get_parent()
	original_position = position

	# Clear previous occupancy if picking up from a grid
	if original_parent and original_parent.is_in_group("drop_zone") and original_parent.has_meta("occupied_by"):
		if original_parent.get_meta("occupied_by") == self:
			original_parent.set_meta("occupied_by", null)

	drag_offset = get_viewport().get_mouse_position() - global_position
	global_position = get_viewport().get_mouse_position() - drag_offset

func _stop_drag(event: InputEventMouseButton) -> void:
	dragging = false
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var drop_target: Control = _get_drop_target_at_point(mouse_pos)

	if drop_target:
		_place_on_drop_target(drop_target)
	else:
		_restore_original_position()

func _place_on_drop_target(drop_target: Control) -> void:
	# Find current slot dynamically (important for repeated swaps)
	var my_slot: Control = null
	for node in get_tree().get_nodes_in_group("drop_zone"):
		if node.has_meta("occupied_by") and node.get_meta("occupied_by") == self:
			my_slot = node
			break

	# If dropped back on same slot, just snap
	if drop_target == my_slot:
		drop_target.set_meta("occupied_by", self)
		_snap_to_target(drop_target)
		in_shop = false
		return

	var occupant: Control = null
	if drop_target.has_meta("occupied_by"):
		occupant = drop_target.get_meta("occupied_by")

	# Swap only allowed if piece is NOT in shop and occupant is valid
	if ALLOW_SWAP and occupant != null and is_instance_valid(occupant) and occupant != self and not in_shop:
		_swap_with_occupant(drop_target, occupant, my_slot)
		return
	elif occupant != null:
		_restore_original_position()
		return

	# Free to drop
	_move_to_target(drop_target)
	drop_target.set_meta("occupied_by", self)
	_snap_to_target(drop_target)
	in_shop = false

func _move_to_target(drop_target: Control) -> void:
	if get_parent() != drop_target:
		if get_parent():
			get_parent().remove_child(self)
		drop_target.add_child(self)

func _swap_with_occupant(drop_target: Control, occupant: Control, my_slot: Control) -> void:
	# Determine occupant's current slot dynamically
	var occupant_slot: Control = null
	for node in get_tree().get_nodes_in_group("drop_zone"):
		if node.has_meta("occupied_by") and node.get_meta("occupied_by") == occupant:
			occupant_slot = node
			break

	# Fallbacks
	if my_slot == null:
		my_slot = original_parent
	if occupant_slot == null:
		occupant_slot = occupant.get_parent()

	# Move occupant into my current slot
	if occupant_slot != null and my_slot != null:
		if occupant.get_parent():
			occupant.get_parent().remove_child(occupant)
		my_slot.add_child(occupant)
		my_slot.set_meta("occupied_by", occupant)

	# Move self into drop_target
	if get_parent():
		get_parent().remove_child(self)
	drop_target.add_child(self)
	drop_target.set_meta("occupied_by", self)
	in_shop = false

	# Snap both pieces
	_snap_to_target(drop_target)
	if is_instance_valid(occupant) and occupant.has_method("_snap_to_target"):
		occupant._snap_to_target(my_slot)

func _restore_original_position() -> void:
	if original_parent and get_parent() != original_parent:
		if get_parent():
			get_parent().remove_child(self)
		original_parent.add_child(self)

	position = original_position

	if original_parent and original_parent.is_in_group("drop_zone"):
		original_parent.set_meta("occupied_by", self)

func _snap_to_target(drop_target: Control) -> void:
	var local_pos: Vector2 = drop_target.get_local_mouse_position() - drag_offset

	if drop_target.has_meta("cell_size"):
		var cell = drop_target.get_meta("cell_size")
		if typeof(cell) == TYPE_VECTOR2:
			position = _snap_to_grid(local_pos, cell)
		else:
			position = _clamp_inside(drop_target, local_pos)
	elif drop_target.has_meta("center") and bool(drop_target.get_meta("center")):
		position = (drop_target.size - size) / 2
	else:
		position = _clamp_inside(drop_target, local_pos)

func _snap_to_grid(pos: Vector2, cell_size: Vector2 = Vector2(100, 100)) -> Vector2:
	return Vector2(
		int((pos.x / cell_size.x) + 0.5) * cell_size.x,
		int((pos.y / cell_size.y) + 0.5) * cell_size.y
	)

func _clamp_inside(target: Control, pos: Vector2) -> Vector2:
	var max_x = max(0, target.size.x - size.x)
	var max_y = max(0, target.size.y - size.y)
	return Vector2(clamp(pos.x, 0, max_x), clamp(pos.y, 0, max_y))

func _get_drop_target_at_point(point: Vector2) -> Control:
	for node in get_tree().get_nodes_in_group("drop_zone"):
		if node is Control:
			var rect = Rect2(node.global_position, node.size)
			if rect.has_point(point):
				return node
	return null
