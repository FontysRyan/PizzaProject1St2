extends Node

# --- Buff System ---
enum Buff {
	TANKIER,
	ATTACK,
	SPEED
}

@onready var panel_scene = preload("res://unit_panel.tscn")
# Tracks which unit is in which panel
var build_slots := {}  # { "Panel_1": "Archer" / "empty" }

func _ready():
	for panel: Panel in get_children():
		var j: int = 0
		for i in Stats.units:
			if i != null:
				panel = get_child(j)
				i.bought = true
				panel.add_child(i)
			j += 1
			if panel is Panel:
				if panel.get_child_count() > 0:
					build_slots[panel.name] = panel.get_child(0).name
				else:
					build_slots[panel.name] = "empty"

	# Assign buffs after setup
	assign_buffs_to_panels()

func _process(delta):
	var unit_names := []  # Collects all 9 slot resource names

	for panel in get_children():
		if panel is Panel:
			var child_name: Unit_Panel = null

			if panel.get_child_count() > 0:
				var unit_tile = panel.get_child(0)
				
				if "panel" in unit_tile and unit_tile.panel:
					var p = unit_tile.panel
					#print("q" + p.name)
					if p is UnitPanel:
						# If it's a resource, get the file name
						var temp_panel = panel_scene.instantiate()
						temp_panel.panel = unit_tile.panel
						temp_panel._fill_panel()
						child_name = temp_panel
					else:
						child_name = null
				else:
					child_name = null

			# Detect slot change
			if child_name != null:
				if build_slots.get(panel) != child_name.panel:
					build_slots[panel] = child_name.panel

					var slot_index = int(panel.name.replace("Panel_", ""))
					GameController.update_build_slot(slot_index, child_name)
			else:
				var slot_index = int(panel.name.replace("Panel_", ""))
				GameController.clear_build_slot(slot_index)


			unit_names.append(child_name)

	# Optional debugging snapshot
	if unit_names.size() == 9:
		pass



# Public API
func get_unit_at(panel_name: String) -> String:
	return build_slots.get(panel_name, "empty")
	
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
	while assigned.size() < buffs_to_assign:
		var panel = panels.pick_random()
		if panel.get_meta("buff_data") == null:
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
	if not is_instance_valid(Stats):
		print("Stats singleton invalid or missing.")
		return

	var buff_data := []
	for i in range(1, 10):
		var panel_name = "Panel%d" % i
		var panels = get_children().filter(func(p): return p is Panel and p.name == panel_name)
		if panels.size() == 0:
			buff_data.append(null)
			continue
		var panel = panels[0]
		var buff = panel.get_meta("buff_data")
		buff_data.append(buff)

	Stats.panel_buffs = buff_data
	print("Exported buffs to Stats:", buff_data)
