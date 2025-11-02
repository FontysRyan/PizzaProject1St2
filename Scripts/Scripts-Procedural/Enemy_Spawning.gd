extends Node

@export var unit_scene: PackedScene
enum Marker_Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Marker_Faction
@export var units_folder_path: String = "res://Resources/units/"
signal enemy_units_spawned

func _ready():
	var unit_types = load_unit_types(units_folder_path)
	print("Loaded unit types:", unit_types.size())

	var spawn_points: Array = []
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

	if spawn_points.is_empty():
		push_error("No Marker2D spawn points found!")
		return


	var wave_number = Stats.wave
	var min_units = clamp(wave_number, 1, spawn_points.size())
	var max_units = clamp(wave_number + 1, 1, spawn_points.size())
	if min_units > max_units:
		min_units = max_units
	var units_to_spawn = randi_range(min_units, max_units)

	spawn_points.shuffle()
	var chosen_markers = spawn_points.slice(0, units_to_spawn)

	for marker in chosen_markers:
		var random_unit_data = unit_types.pick_random()
		var unit_type_name = random_unit_data.get_meta("unit_type_name", "Unknown")

		print("Spawning random unit:", unit_type_name)

		var unit = unit_scene.instantiate()
		unit.global_position = marker.global_position
		unit.faction = faction
		unit.unit_type = unit_type_name
		unit.stats = random_unit_data
		unit.add_to_group("Enemy_units")
		unit.add_to_group("units")

		add_child(unit)

		if unit.has_method("initialize_unit"):
			unit.initialize_unit()

		if unit.stats:
			print("Spawned:", unit.name, "| Type:", unit.unit_type, "| Faction:", faction)
		else:
			print("Unit stats missing for:", unit.unit_type)
	call_deferred("emit_signal", "enemy_units_spawned")


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
				res.set_meta("unit_type_name", file_name.get_basename())
				unit_types.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()

	return unit_types
