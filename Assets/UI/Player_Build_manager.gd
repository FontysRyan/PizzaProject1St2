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
	for panel in get_children():
		if panel is Panel:
			var child_name = null
			if panel.get_child_count() > 0:
				child_name = panel.get_child(0).name

			if build_slots[panel.name] != child_name:
				build_slots[panel.name] = child_name
				if child_name:
					print(panel.name, " now has unit: ", child_name)
				else:
					print(panel.name, " is now empty")

			

	



# Public API
func get_unit_at(panel_name: String) -> String:
	return build_slots.get(panel_name, null)
