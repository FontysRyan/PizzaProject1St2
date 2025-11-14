extends Node

# --- Buff System ---
enum Buff {
	TANKIER,
	ATTACK,
	SPEED
}

@onready var panel_scene = preload("res://unit_panel.tscn")

func _ready():
	for panel: Panel in get_children():
		var slot_index = int(panel.name.replace("Panel_", ""))
		if Stats.units.size() != 0:
			$"../../BottomBar/FightButton".disabled = false
			var unit = Stats.units[slot_index-1]
			if unit != null:
				var child_name: Unit_Panel = null
				if unit.scene_file_path != "res://Assets/UI/PlacementIndicator.tscn":
					var temp_panel = panel_scene.instantiate()
					print(temp_panel)
					temp_panel.premade_panel = unit.premade_panel
					temp_panel.unit_level = unit.unit_level
					temp_panel.bought = true
					temp_panel.checked = false
					temp_panel.in_shop = false
					temp_panel._fill_panel()
					child_name = temp_panel
					panel.add_child(child_name)
					panel.set_meta("occupied_by", child_name)
					GameController.update_build_slot(slot_index, child_name)
					Stats.units = GameController.get_build_slots()
	# Assign buffs after setup
	assign_buffs_to_panels()

func _process(delta):
	for panel in get_children():
		if panel is Panel:
			var slot_index = int(panel.name.replace("Panel_", ""))
			var unit = GameController.get_unit_slot(slot_index)
			if unit == null:
				if panel.get_child_count() > 0:
					var unit_tile = panel.get_child(0)
					if unit_tile.scene_file_path != "res://Assets/UI/PlacementIndicator.tscn":
						$"../../BottomBar/FightButton".disabled = false
						if "panel" in unit_tile and unit_tile.panel:
							var child_name: Unit_Panel = null
							var p = unit_tile.panel
							if p is UnitPanel:
								var temp_panel = panel_scene.instantiate()
								print(temp_panel)
								temp_panel.premade_panel = unit_tile.premade_panel
								temp_panel.unit_level = unit_tile.unit_level
								temp_panel._fill_panel()
								child_name = temp_panel
								child_name.checked = true
								GameController.update_build_slot(slot_index, child_name)
								Stats.units = GameController.get_build_slots()
							else:
								GameController.clear_build_slot(slot_index)
								Stats.units = GameController.get_build_slots()
					else:
						GameController.clear_build_slot(slot_index)
						Stats.units = GameController.get_build_slots()
				else:
					GameController.clear_build_slot(slot_index)
					Stats.units = GameController.get_build_slots()
			elif !unit.checked:
				if panel.get_child_count() > 0:
					var unit_tile = panel.get_child(0)
					if unit_tile.scene_file_path != "res://Assets/UI/PlacementIndicator.tscn":
						$"../../BottomBar/FightButton".disabled = false
						if "panel" in unit_tile and unit_tile.panel:
							var child_name: Unit_Panel = null
							var p = unit_tile.panel
							if p is UnitPanel:
								var temp_panel = panel_scene.instantiate()
								print(temp_panel)
								temp_panel.premade_panel = unit_tile.premade_panel
								temp_panel.unit_level = unit_tile.unit_level
								temp_panel._fill_panel()
								child_name = temp_panel
								child_name.checked = true
								GameController.update_build_slot(slot_index, child_name)
								Stats.units = GameController.get_build_slots()
							else:
								GameController.clear_build_slot(slot_index)
								Stats.units = GameController.get_build_slots()
					else:
						GameController.clear_build_slot(slot_index)
						Stats.units = GameController.get_build_slots()
				else:
					GameController.clear_build_slot(slot_index)
					Stats.units = GameController.get_build_slots()
			else:
				if panel.get_child_count() == 0:
					GameController.clear_build_slot(slot_index)
					Stats.units = GameController.get_build_slots()
				else:
					GameController.update_build_slot(slot_index, unit)
					Stats.units = GameController.get_build_slots()

# --- Buff Management ---
func assign_buffs_to_panels():
	var panels = get_children().filter(func(p): return p is Panel)

	if panels.is_empty():
		print("No panels found for buffs.")
		return

	# Determine round progression
	var round = Stats.rounds_survived
	# min_buffs is always 0
	var min_buffs = 0
	# max_buffs grows each round, but cannot exceed panels.size()
	var max_buffs = clamp(round, 0, panels.size())

	var buffs_to_assign = randi_range(min_buffs, max_buffs)
	print("Assigning %d buffs to %d panels (round %d)" % [buffs_to_assign, panels.size(), round])

	# Clear old buffs
	for p in panels:
		p.set_meta("buff_data", null)
		p.modulate = Color.WHITE

	# Assign new buffs
	var assigned = []
	panels.shuffle()
	for i in range(buffs_to_assign):
		var panel = panels[i]
		var random_buff = Buff.keys().pick_random()
		panel.set_meta("buff_data", random_buff)

		match random_buff:
			"ATTACK":
				panel.modulate = Color.RED
			"TANKIER":
				panel.modulate = Color.BLUE
			"SPEED":
				panel.modulate = Color.GREEN

		assigned.append(panel)
		print("Assigned %s buff to %s" % [random_buff, panel.name])

	print("Buff assignment complete! %d panels have buffs." % assigned.size())

func export_buffs_to_stats():

	var buff_data := []
	# Build a dictionary mapping panel names to panel objects
	var panel_map = {}
	for p in get_children():
		if p is Panel:
			panel_map[p.name] = p
	for i in range(1, 10):
		var panel_name = "Panel%d" % i
		if not panel_map.has(panel_name):
			buff_data.append(null)
			continue
		var panel = panel_map[panel_name]
		var buff = panel.get_meta("buff_data")
		buff_data.append(buff)

	Stats.panel_buffs = buff_data
	print("Exported buffs to Stats:", buff_data)
