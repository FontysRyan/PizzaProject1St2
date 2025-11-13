extends Node

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
				i._place_on_drop_target(panel)
			j += 1
			if panel is Panel:
				if panel.get_child_count() > 0:
					build_slots[panel.name] = panel.get_child(0).name
				else:
					build_slots[panel.name] = "empty"

func _process(delta):
	var unit_names := []  # Collects all 9 slot resource names

	for panel in get_children():
		if panel is Panel:
			var child_name: Unit_Panel = null

			if panel.get_child_count() > 0:
				var i = panel.get_child_count() - 1
				var unit_tile = panel.get_child(i)
				
				if "panel" in unit_tile and unit_tile.panel:
					var p = unit_tile.panel
					#print("q" + p.name)
					if p is UnitPanel:
						# If it's a resource, get the file name
						var temp_panel = panel_scene.instantiate()
						temp_panel.premade_panel = unit_tile.premade_panel
						temp_panel.unit_level = unit_tile.unit_level
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
