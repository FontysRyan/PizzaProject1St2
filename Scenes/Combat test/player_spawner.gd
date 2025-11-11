extends Node

@export var unit_scene: PackedScene
enum Marker_Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Marker_Faction
var units_to_spawn = 1

# Define signals
signal player_units_spawned
signal enemy_units_spawned

func _ready():
	var spawned_count = 0
	var spawn_points = get_children()

	for i in range(spawn_points.size()):
		if spawned_count == units_to_spawn:
			break
		var marker = spawn_points[i]
		if not marker is Marker2D:
			continue

		
		# Instantiate unit scene
		var unit = unit_scene.instantiate()
		unit.global_position = marker.global_position
		unit.faction = faction
		unit.unit_type = PickUnitType()

		if faction == Marker_Faction.FRIENDLY:
			unit.add_to_group("Friendly_units")
			unit.collision_layer = 1
		else:
			unit.add_to_group("Enemy_units")
			unit.collision_layer = 2

		unit.add_to_group("units")
		add_child(unit)
		spawned_count += 1


	if spawned_count > 0:
		if faction == Marker_Faction.FRIENDLY:
			call_deferred("emit_signal", "player_units_spawned")
		else:
			call_deferred("emit_signal", "enemy_units_spawned")

# Fallback random unit type picker if needed
func PickUnitType() -> String:
	var num = randi() % 4 + 1
	match num:
		1: return "Knight"
		2: return "Knight"
		3: return "Knight"
		4: return "Knight"
	return num
