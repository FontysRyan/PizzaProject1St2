extends Node

# Tracks which unit is in which panel
var build_slots := {}  # { "Panel_1": "Archer" / "empty" }

func _ready():
	for panel in get_children():
		if panel is Panel:
			if panel.get_child_count() > 0:
				build_slots[panel.name] = panel.get_child(0).name
			else:
				build_slots[panel.name] = "empty"

func _process(delta):
	var unit_names := []  # Collects all 9 slot resource names

	for panel in get_children():
		if panel is Panel:
			var child_name = "empty"  # default if no child

			if panel.get_child_count() > 0:
				var unit_tile = panel.get_child(0)
				
				# Safely check for resource path
				if "panel" in unit_tile and unit_tile.panel:
					child_name = unit_tile.panel.resource_path.get_file()
				else:
					child_name = unit_tile.name

			# Detect slot change
			if build_slots.get(panel.name, "") != child_name:
				build_slots[panel.name] = child_name

				var slot_index = int(panel.name.replace("Panel_", ""))
				GameController.update_build_slot(slot_index, child_name)

				if child_name != "empty":
					print(panel.name, " now has unit: ", child_name)
				else:
					print(panel.name, " is now empty")

			unit_names.append(child_name)

	# Optional debugging snapshot
	if unit_names.size() == 9:
		pass


# Public API
func get_unit_at(panel_name: String) -> String:
	return build_slots.get(panel_name, "empty")
