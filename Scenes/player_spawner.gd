extends Node

@export var unit_scene: PackedScene # fallback scene if needed
enum Marker_Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Marker_Faction = Marker_Faction.FRIENDLY
var units_to_spawn = 9

signal player_units_spawned
#signal enemy_units_spawned

func _ready():
	if faction != Marker_Faction.FRIENDLY:
		return

	var spawned_count = 0
	var spawn_points = get_children()

	# Get the 9 unit names from GameController
	var build_slots: Array = GameController.get_build_slots() # ["res://Resources/units/Archer.tres", ...]

	for i in range(units_to_spawn):
		var marker = spawn_points[i]
		if marker is not Marker2D:
			continue

		var unit_path = build_slots[i]
		if unit_path == null or unit_path == "":
			continue

		# Remove .tres and path, leave only the scene/unit name
		var unit_name = unit_path.get_file().get_basename()  # "Archer.tres" → "Archer"

		# Load the unit scene dynamically
		var unit_scene_to_spawn = load("res://Units/%s.tscn" % unit_name)
		if not unit_scene_to_spawn:
			push_warning("Unit scene not found: " + unit_name)
			continue

		var unit = unit_scene_to_spawn.instantiate()
		unit.global_position = marker.global_position
		unit.faction = faction
		unit.unit_type = unit_name
		unit.add_to_group("Friendly_units")
		unit.collision_layer = 1
		unit.add_to_group("units")

		add_child(unit)
		spawned_count += 1

	if spawned_count > 0:
		call_deferred("emit_signal", "player_units_spawned")
