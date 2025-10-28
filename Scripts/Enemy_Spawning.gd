extends Node

@export var unit_scene: PackedScene
enum Marker_Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Marker_Faction
@export var units_folder_path: String = "res://Resources/units/"

func _ready():
	var unit_types = load_unit_types(units_folder_path)
	if unit_types.is_empty():
		push_error("No unit .tres files found at: " + units_folder_path)
		return
	
	var spawn_points = get_children()
	for marker in spawn_points:
		if marker is Marker2D:
			var random_unit_data = unit_types.pick_random()
			print("Spawning random unit:", random_unit_data.resource_name)

			var unit = unit_scene.instantiate()  # use shared unit scene
			unit.global_position = marker.global_position
			unit.faction = faction
			unit.unit_type = random_unit_data.resource_name.replace(".tres", "")
			unit.stats = random_unit_data  # give the resource data
			add_child(unit)


func load_unit_types(folder_path: String) -> Array:
	var unit_types: Array = []
	var dir = DirAccess.open(folder_path)
	if dir == null:
		push_error("Could not open directory: " + folder_path)
		return unit_types

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") and file_name != "UnitStats.tres":
			var res = load(folder_path + file_name)
			if res:
				unit_types.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()
	return unit_types
