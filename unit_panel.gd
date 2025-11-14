class_name Unit_Panel
extends Panel

@export var placement_indicator_scene: PackedScene
var placement_indicator: Control = null

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
var tile_buffed: bool = false
var buff: String = ""
var checked: bool = false

var active_indicators: Array = []

# -------------------------------
# Ready
# -------------------------------
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS

# -------------------------------
# Indicator functions
# -------------------------------
func _show_valid_indicators():
	_hide_all_indicators()  # remove old indicators first

	for zone in get_tree().get_nodes_in_group("drop_zone"):
		if zone.name == "SellUnitZone":
			continue  # skip sell zone

		if not placement_indicator_scene:
			continue

		var indicator_instance = placement_indicator_scene.instantiate()
		zone.add_child(indicator_instance)

		# Top-center anchor
		indicator_instance.anchor_left = 0.5
		indicator_instance.anchor_top = 0.0
		indicator_instance.anchor_right = 0.5
		indicator_instance.anchor_bottom = 0.0
		var base_pos = Vector2(0, -indicator_instance.size.y * 0.5)
		indicator_instance.position = base_pos

		# Safely get the occupant
		var raw_occupant = zone.get_meta("occupied_by") if zone.has_meta("occupied_by") else null
		var occupied = false
		var occupant: Unit_Panel = null

		if raw_occupant != null and is_instance_valid(raw_occupant):
			occupant = raw_occupant
			occupied = true
		else:
			zone.set_meta("occupied_by", null)

		# Decide which icons to show
		var show_glove = false
		var show_rewind = false

		if occupied and occupant != null and is_instance_valid(occupant) and occupant.panel != null:
			if occupant.panel.unit_name == panel.unit_name and occupant.unit_level < 5:
				# Same unit → mergeable
				show_glove = true
			else:
				# Different unit → rotation/replacement
				show_rewind = true
		else:
			# Empty tile
			show_glove = true

		# Shop drag
		if in_shop:
			if indicator_instance.has_node("GloveIcon"):
				indicator_instance.get_node("GloveIcon").visible = show_glove
			if indicator_instance.has_node("RewindIcon"):
				indicator_instance.get_node("RewindIcon").visible = show_rewind
		else:
			# Board drag
			if indicator_instance.has_node("GloveIcon"):
				indicator_instance.get_node("GloveIcon").visible = show_glove
			if indicator_instance.has_node("RewindIcon"):
				indicator_instance.get_node("RewindIcon").visible = show_rewind

		# Start invisible for fade
		indicator_instance.modulate.a = 0
		indicator_instance.visible = true

		# Fade in
		var fade_tween = indicator_instance.create_tween()
		fade_tween.tween_property(indicator_instance, "modulate:a", 1.0, 0.3)

		# Animate bobbing
		_animate_indicator(indicator_instance, base_pos)

		active_indicators.append(indicator_instance)



func _animate_indicator(indicator: Control, base_pos: Vector2) -> void:
	var down_pos = base_pos + Vector2(0, 10)
	var move_time = 0.25

	var tween = indicator.create_tween()
	tween.set_loops()  # infinite looping
	tween.tween_property(indicator, "position", down_pos, move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(indicator, "position", base_pos, move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _hide_all_indicators():
	for indicator in active_indicators:
		if is_instance_valid(indicator):
			var fade_tween = indicator.create_tween()
			fade_tween.tween_property(indicator, "modulate:a", 0.0, 0.3).connect("finished", Callable(indicator, "queue_free"))
	active_indicators.clear()

# -------------------------------
# Panel creation / update
# -------------------------------
func _create_empty_panel() -> void:
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

# -------------------------------
# Drag & drop
# -------------------------------
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
	if original_parent and original_parent.is_in_group("drop_zone") and original_parent.has_meta("occupied_by"):
		if original_parent.get_meta("occupied_by") == self:
			original_parent.set_meta("occupied_by", null)
	drag_offset = get_viewport().get_mouse_position() - global_position
	global_position = get_viewport().get_mouse_position() - drag_offset

	_show_valid_indicators()


func _stop_drag(event: InputEventMouseButton) -> void:
	dragging = false
	_hide_all_indicators()
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var drop_target: Control = _get_drop_target_at_point(mouse_pos)

	if bought or Stats.gold >= panel.rarity.cost:
		if drop_target:
			_place_on_drop_target(drop_target)
		else:
			_restore_original_position()
	else:
		_restore_original_position()


# -------------------------------
# Drop & swap logic
# -------------------------------
func _place_on_drop_target(drop_target: Control) -> void:
	var price = panel.rarity.cost
	var my_slot: Control = null

	if drop_target.name == "SellUnitZone":
		if bought:
			Stats.gold += price - 1
			self.queue_free()
			return
		else:
			_restore_original_position()
			return

	for node in get_tree().get_nodes_in_group("drop_zone"):
		if node.has_meta("occupied_by") and node.get_meta("occupied_by") == self:
			my_slot = node
			break

	if drop_target == my_slot:
		drop_target.set_meta("occupied_by", self)
		_snap_to_target(drop_target)
		in_shop = false
		return

	var occupant: Control = null
	if drop_target.has_meta("occupied_by"):
		occupant = drop_target.get_meta("occupied_by")

	if occupant != null and !occupant.in_shop:
		if occupant.panel.unit_name == panel.unit_name:
			if bought:
				if occupant.unit_level == 5 or self.unit_level == 5:
					_restore_original_position()
					return
				else:
					original_parent.set_meta("occupied_by", null)
					self.unit_level += occupant.unit_level
					self._update_self()
					_swap_with_occupant(drop_target, occupant, my_slot)
					occupant.queue_free()
					in_shop = false
					return
			else:
				if occupant.unit_level == 5 or self.unit_level == 5:
					_restore_original_position()
					return
				else:
					bought = true
					Stats._take_gold(price)
					original_parent.set_meta("occupied_by", null)
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

	_move_to_target(drop_target)
	drop_target.set_meta("occupied_by", self)
	_snap_to_target(drop_target)
	in_shop = false

	if not bought:
		bought = true
		Stats._take_gold(price)


func _move_to_target(drop_target: Control) -> void:
	if get_parent() != drop_target:
		if get_parent():
			get_parent().remove_child(self)
		drop_target.add_child(self)


func _swap_with_occupant(drop_target: Control, occupant: Control, my_slot: Control) -> void:
	var occupant_slot: Control = null
	for node in get_tree().get_nodes_in_group("drop_zone"):
		if node.has_meta("occupied_by") and node.get_meta("occupied_by") == occupant:
			occupant_slot = node
			break

	if my_slot == null:
		my_slot = original_parent
	if occupant_slot == null:
		occupant_slot = occupant.get_parent()

	if occupant_slot != null and my_slot != null:
		if occupant.get_parent():
			occupant.get_parent().remove_child(occupant)
		my_slot.add_child(occupant)
		my_slot.set_meta("occupied_by", occupant)

	if get_parent():
		get_parent().remove_child(self)
	drop_target.add_child(self)
	drop_target.set_meta("occupied_by", self)
	in_shop = false

	_snap_to_target(drop_target)
	if is_instance_valid(occupant) and occupant.has_method("_snap_to_target"):
		occupant._snap_to_target(my_slot)


func _restore_original_position() -> void:
	if original_parent:
		if get_parent() != original_parent:
			if get_parent():
				get_parent().remove_child(self)
			original_parent.add_child(self)
		position = original_position
		if original_parent.is_in_group("drop_zone"):
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


# -------------------------------
# Level up logic
# -------------------------------
func level_up() -> UnitStats:
	var stats = premade_panel.unit_stats.duplicate()
	match unit_level:
		1: return stats
		2:
			stats.max_hp *= 2.2
			stats.attack_speed /= 1.1
			stats.damage *= 1.9
			stats.crit_chance *= 1.1
			if stats.type == "ranged":
				stats.range *= 1.2
			return stats
		3:
			stats.max_hp *= 3.1
			stats.attack_speed /= 1.2
			stats.movement_speed *= 1.5
			stats.damage *= 2.9
			stats.crit_chance *= 1.2
			if stats.type == "ranged":
				stats.range *= 1.6
			return stats
		4:
			stats.max_hp *= 4.1
			stats.attack_speed /= 1.3
			stats.damage *= 3.8
			stats.crit_chance *= 1.3
			if stats.type == "ranged":
				stats.range *= 1.8
			return stats
		5:
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
#i broke something
