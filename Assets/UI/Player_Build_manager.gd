extends Node

# Tracks which unit is in which panel
var build_slots := {}  # { "Panel_1": "Archer" / null }

func _ready():
	for panel in get_children():
		if panel is Panel:
			if panel.get_child_count() > 0:
				build_slots[panel.name] = panel.get_child(0).name
			else:
				build_slots[panel.name] = null

func _process(delta):
	var unit_names := []  # Will store 9 unit resource names (or null)
	
	for panel in get_children():
		if panel is Panel:
			var child_name = null
			var unit_tile: Node = null
			
			if panel.get_child_count() > 0:
				unit_tile = panel.get_child(0)
				# Use resource name if available
				if unit_tile.panel != null:
					child_name = unit_tile.panel.resource_path.get_file()
				else:
					child_name = unit_tile.name
			
			if build_slots[panel.name] != child_name:
				build_slots[panel.name] = child_name
				if child_name:
					print(panel.name, " now has unit: ", child_name)
				else:
					print(panel.name, " is now empty")
			
			unit_names.append(child_name)
	
	GameController.update_build_slots(unit_names)


			

	



# Public API
func get_unit_at(panel_name: String) -> String:
	return build_slots.get(panel_name, null)
