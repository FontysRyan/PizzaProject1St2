extends Node

# --- Buff System ---
enum Buff {
	TANKIER,
	ATTACK,
	SPEED
}

var build_slots := {}  # { "Panel_1": "Archer" / "empty" }

func _ready():
	randomize()

	# Initialize build slots
	for panel in get_children():
		if panel is Panel:
			if panel.get_child_count() > 0:
				build_slots[panel.name] = panel.get_child(0).name
			else:
				build_slots[panel.name] = "empty"

	# Assign buffs after setup
	assign_buffs_to_panels()

func _process(delta):
	var unit_names := []

	for panel in get_children():
		if panel is Panel:
			var child_name: String = "empty"

			if panel.get_child_count() > 0:
				var unit_tile = panel.get_child(0)
				if "panel" in unit_tile and unit_tile.panel:
					var p = unit_tile.panel
					if p is UnitPanel:
						child_name = p.unit_name
					else:
						child_name = "unknown"
				else:
					child_name = "unknown"

			# Detect slot change
			if build_slots.get(panel.name) != child_name:
				build_slots[panel.name] = child_name

				var slot_index = int(panel.name.replace("Panel", ""))
				GameController.update_build_slot(slot_index, child_name)

				if child_name != "empty" && child_name != "unknown" && child_name != null:
					print(panel.name, " now has unit: ", child_name)
				else:
					print(panel.name, " is now empty")

			unit_names.append(child_name)

	# Optional debugging snapshot
	if unit_names.size() == 9:
		pass


# --- Public API ---
func get_unit_at(panel_name: String) -> String:
	return build_slots.get(panel_name, "empty")


# --- Buff Management ---
func assign_buffs_to_panels():
	var panels = get_children().filter(func(p): return p is Panel)

	if panels.is_empty():
		print("No panels found for buffs.")
		return

	# Determine round progression (replace with your actual Stats logic)
	var round = Stats.rounds_survived

	# Scale buff count
	var min_buffs = clamp(round, 1, panels.size())
	var max_buffs = clamp(round + 1, 1, panels.size())
	if min_buffs > max_buffs:
		min_buffs = max_buffs

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
