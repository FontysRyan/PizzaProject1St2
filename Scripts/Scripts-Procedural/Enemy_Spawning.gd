extends Node

@export var unit_scene: PackedScene
enum Marker_Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Marker_Faction
@export var units_folder_path: String = "res://Resources/units/"

func _ready():
	var unit_types = load_unit_types(units_folder_path)
	print("Loaded unit types:", unit_types.size())

	var spawn_points = get_children()
	for marker in spawn_points:
		if marker is Marker2D:
			var random_unit_data = unit_types.pick_random()
			var unit_type_name = random_unit_data.get_meta("unit_type_name", "Unknown")

			print("Spawning random unit:", unit_type_name)

			var unit = unit_scene.instantiate()
			unit.global_position = marker.global_position

			unit.faction = faction
			unit.unit_type = unit_type_name
			unit.stats = random_unit_data

			print("Assigned unit_type:", unit.unit_type)

			add_child(unit)

			if unit.has_method("initialize_unit"):
				unit.initialize_unit()

			if unit.stats:
				var hp = unit.stats.max_hp if "max_hp" in unit.stats else "?"
				var dmg = unit.stats.damage if "damage" in unit.stats else "?"
				print("Spawned:", unit.name, "| Type:", unit.unit_type, "| Faction:", faction, "| HP:", hp, "| Damage:", dmg)
			else:
				print("Unit stats missing for:", unit.unit_type)


func load_unit_types(folder_path: String) -> Array:
	var unit_types: Array = []
	var dir = DirAccess.open(folder_path)
	if dir == null:
		push_error("Could not open directory: " + folder_path)
		return unit_types

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		print("Checking file:", file_name)
		if file_name.ends_with(".tres") and file_name != "UnitStats.tres":
			var res = load(folder_path + file_name)
			if res:
				res.set_meta("unit_type_name", file_name.get_basename())
				unit_types.append(res)
				print("Loaded:", file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	print("Total loaded:", unit_types.size())
	return unit_types
