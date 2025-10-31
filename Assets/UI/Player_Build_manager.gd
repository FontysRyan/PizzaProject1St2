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
			var child_name: String = "empty"

			if panel.get_child_count() > 0:
				var unit_tile = panel.get_child(0)
				
				if "panel" in unit_tile and unit_tile.panel:
					var p = unit_tile.panel
					#print("q" + p.name)
					if p is UnitPanel:
						# If it's a resource, get the file name
						child_name = p.unit_name
					else:
						child_name = "unknown"
				else:
					child_name = "unknown"

			# Detect slot change
			if build_slots.get(panel.name) != child_name:
				build_slots[panel.name] = child_name

				var slot_index = int(panel.name.replace("Panel_", ""))
				GameController.update_build_slot(slot_index, child_name)

				if child_name != "empty" || child_name != "unknown" || child_name != null:
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
