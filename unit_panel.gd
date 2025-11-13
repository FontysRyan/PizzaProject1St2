class_name Unit_Panel
extends Panel

<<<<<<< HEAD
@export var placement_indicator_scene: PackedScene
var placement_indicator: Control = null

=======
>>>>>>> parent of db6ad90 (fuck yeah)
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_parent: Node = null
var original_position: Vector2 = Vector2.ZERO
var in_shop: bool = true
const ALLOW_SWAP: bool = true
var premade_panel = preload("res://Resources/unit panels/UnitPanel.gd")
var panel: UnitPanel
var unit_level: int = 1
var bought: bool = false
var checked: bool = false
var tile_buffed: bool = false
var buff: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS

func _create_empty_panel() -> void:
	# Ensure these nodes are correctly referenced and instantiated if needed
	if $SpriteTexture == null:
		print("Error: SpriteTexture node not found")
	if $PriceLabel == null:
		print("Error: PriceLabel node not found")
	if $LevelLabel == null:
		print("Error: LevelLabel node not found")

func _fill_panel() -> void:
	var temp_panel: UnitPanel = premade_panel
	panel = temp_panel.duplicate()
	panel.unit_stats = level_up()
	var color = panel.rarity.color
	add_theme_color_override("UnitPanel", color)
	var texture = panel.unit_stats.texture
	$SpriteTexture.texture = texture
	var price = panel.rarity.cost
	$PriceLabel.text = str(price)
	var level = "Lvl: " + str(unit_level)
	$LevelLabel.text = level
	$Tooltip.parent = self
	
func _update_self() -> void:
	panel.unit_stats = level_up()
	var color = panel.rarity.color
	add_theme_color_override("UnitPanel", color)
	var texture = panel.unit_stats.texture
	$SpriteTexture.texture = texture
	var price = panel.rarity.cost
	$PriceLabel.text = str(price)
	var level = "Lvl: " + str(unit_level)
	$LevelLabel.text = level
	$Tooltip.parent = self
	$Tooltip.request_ready()

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
	if bought:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var drop_target: Control = _get_drop_target_at_point(mouse_pos)
		if drop_target:
			_place_on_drop_target(drop_target)
		else:
			_restore_original_position()
	elif Stats.gold >= panel.rarity.cost:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var drop_target: Control = _get_drop_target_at_point(mouse_pos)
		if drop_target:
			_place_on_drop_target(drop_target)
		else:
			_restore_original_position()
	else:
		_restore_original_position()

func _place_on_drop_target(drop_target: Control) -> void:
	# Find current slot dynamically (important for repeated swaps)
	var price = panel.rarity.cost
	var my_slot: Control = null
	if drop_target.name == "SavingLabel":
		if bought:
			var value = price - 1
			Stats.gold += value
			self.queue_free()
			return
		else:
			_restore_original_position()
			return
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
		if drop_target.get_meta("occupied_by") != null:
			occupant = drop_target.get_meta("occupied_by")
	# Swap only allowed if piece is NOT in shop and occupant is valid
	if occupant != null and is_instance_valid(occupant) and occupant != self and !occupant.in_shop:
		if occupant.panel.unit_name == panel.unit_name:
			if bought:
				if occupant.unit_level == 5:
					_restore_original_position()
					return
				else:
					original_parent.remove_meta("occupied_by")
					self.unit_level += occupant.unit_level
					self._update_self()
					_swap_with_occupant(drop_target, occupant, my_slot)
					occupant.queue_free()
					in_shop = false
					return
			else:
				if occupant.unit_level == 5:
					_restore_original_position()
					return
				else:
					bought = true
					Stats._take_gold(price)
					original_parent.remove_meta("occupied_by")
					self.unit_level += occupant.unit_level
					self._update_self()
					_swap_with_occupant(drop_target, occupant, my_slot)
					occupant.queue_free()
					in_shop = false
					return
		else:
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

	# Subtract the price when the panel is successfully placed on a drop target
	if bought:
		return
	else:
		bought = true
		Stats._take_gold(price)

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
	if original_parent and get_parent() == original_parent:
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

func level_up() -> UnitStats:
	var stats = premade_panel.unit_stats.duplicate()
	match unit_level:
		1: #nothing happens
			return stats
		2: #level 2 acquired
			stats.max_hp *= 2.2
			stats.attack_speed /= 1.1
			stats.damage *= 1.9
			stats.crit_chance *= 1.1
			if stats.type == "ranged":
				stats.range *= 1.2
			return stats
		3: #level 3 acquired
			stats.max_hp *= 3.1
			stats.attack_speed /= 1.2
			stats.movement_speed *= 1.5
			stats.damage *= 2.9
			stats.crit_chance *= 1.2
			if stats.type == "ranged":
				stats.range *= 1.6
			return stats
		4: #level 4 acquired
			stats.max_hp *= 4.1
			stats.attack_speed /= 1.3
			stats.damage *= 3.8
			stats.crit_chance *= 1.3
			if stats.type == "ranged":
				stats.range *= 1.8
			return stats
		5: #level 5 acquired
			stats.max_hp *= 5
			stats.attack_speed /= 1.5
			stats.movement_speed *= 2
			stats.damage *= 4.7
			stats.crit_chance *= 1.5
			if stats.type == "ranged":
				stats.range *= 2.1
			return stats
		_:
			return stats
