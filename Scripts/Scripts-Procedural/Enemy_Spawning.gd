extends Node

@export var unit_scene: PackedScene
enum Marker_Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Marker_Faction
@export var units_folder_path: String = "res://Resources/units/"
signal enemy_units_spawned

func _ready():
	#print("Starting first wave:", Stats.wave, " Total waves: ", Stats.waves_in_round)
	enemy_wave_incoming()
	#call_deferred("start_waves") # schedule the wave loop

func start_waves():
	# Start from the *next* wave since the first one already spawned
	Stats.wave += 1

	while Stats.wave <= Stats.waves_in_round:
		# Wait before spawning the next wave
		await get_tree().create_timer(60).timeout

		print("Starting wave:", Stats.wave)
		enemy_wave_incoming()

		Stats.wave += 1


		
	#var unit_types = load_unit_types(units_folder_path)
	#print("Loaded unit types:", unit_types.size())
#
	#var spawn_points: Array = []
	#for child in get_children():
		#if child is Marker2D:
			#spawn_points.append(child)
#
	#if spawn_points.is_empty():
		#push_error("No Marker2D spawn points found!")
		#return
#
#
	#var wave_number = Stats.wave
	#var min_units = clamp(wave_number, 1, spawn_points.size())
	#var max_units = clamp(wave_number + 1, 1, spawn_points.size())
	#if min_units > max_units:
		#min_units = max_units
	#var units_to_spawn = randi_range(min_units, max_units)
#
	#spawn_points.shuffle()
	#var chosen_markers = spawn_points.slice(0, units_to_spawn)
#
	#for marker in chosen_markers:
		#var random_unit_data = unit_types.pick_random()
		#var unit_type_name = random_unit_data.get_meta("unit_type_name", "Unknown")
#
		#var unit = unit_scene.instantiate()
		#unit.global_position = marker.global_position
		#unit.faction = faction
		#unit.unit_type = unit_type_name
		#unit.stats = random_unit_data
		#unit.collision_layer = 2   # Layer: PlayerUnits
		#unit.add_to_group("Enemy_units")
		#unit.add_to_group("units")
#
		#add_child(unit)
	#
		#if unit.has_method("initialize_unit"):
			#unit.initialize_unit()
#
		#if unit.stats:
			#print("Spawned:", unit.name, "| Type:", unit.unit_type, "| Faction:", faction)
		#else:
			#print("Unit stats missing for:", unit.unit_type)
	#call_deferred("emit_signal", "enemy_units_spawned")

func load_unit_types(folder_path: String) -> Array:
	var unit_types: Array = []
	print("Loading enemy units from: ", folder_path)

	var dir := DirAccess.open(folder_path)
	if dir == null:
		push_error("Enemy_Spawning.gd: Cannot open directory: " + folder_path)
		return unit_types

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		var is_dir := dir.current_is_dir()
		print("Found entry:", file_name, " | is_dir:", is_dir)

		if not is_dir:
			var path_for_load := ""
			var name_for_meta := file_name

			# Handle .tres and .tres.remap
			if file_name.ends_with(".tres.remap"):
				# What we load is the original .tres
				path_for_load = folder_path + file_name.trim_suffix(".remap")
				name_for_meta = file_name.trim_suffix(".remap")
			elif file_name.ends_with(".tres"):
				path_for_load = folder_path + file_name
			else:
				# Skip non-.tres stuff like UnitStats.gd.gdc etc.
				file_name = dir.get_next()
				continue

			# Skip UnitStats in any form
			var base_for_skip := name_for_meta.get_file().get_basename()
			if base_for_skip.begins_with("UnitStats"):
				file_name = dir.get_next()
				continue

			print("  Trying to load unit resource:", path_for_load)
			var res := load(path_for_load)
			if res:
				# Clean name: file name without extension
				var meta_name := name_for_meta.get_file().get_basename()
				res.set_meta("unit_type_name", meta_name)
				unit_types.append(res)
			else:
				push_error("Enemy_Spawning.gd: Failed to load resource: " + path_for_load)

		file_name = dir.get_next()

	dir.list_dir_end()

	print("Loaded enemy units:", unit_types)
	return unit_types


func enemy_wave_incoming():
	print("Starting wave:", Stats.wave, " Total waves: ", Stats.waves_in_round)
	var unit_types = load_unit_types(units_folder_path)
	#print("Loaded unit types:", unit_types.size())
	if unit_types.is_empty():
		push_error("Enemy_Spawning.gd: No enemy unit resources found in folder: " + units_folder_path)
		return
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

		var unit = unit_scene.instantiate()
		unit.global_position = marker.global_position
		unit.faction = faction
		unit.unit_type = unit_type_name
		unit.stats = random_unit_data
		unit.collision_layer = 2   # Layer: PlayerUnits
		unit.add_to_group("Enemy_units")
		unit.add_to_group("units")

		add_child(unit)
	
		if unit.has_method("initialize_unit"):
			unit.initialize_unit()
			#===================================================================
		#if unit.stats:
			#print("Spawned:", unit.name, "| Type:", unit.unit_type, "| Faction:", faction)
		#else:
			#print("Unit stats missing for:", unit.unit_type)
	call_deferred("emit_signal", "enemy_units_spawned")
