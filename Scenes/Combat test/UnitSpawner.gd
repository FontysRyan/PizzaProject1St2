extends Node

@export var unit_scene: PackedScene
enum Marker_Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Marker_Faction
var units_to_spawn = 9

# Define signals
signal player_units_spawned
signal enemy_units_spawned

func _ready():
	var spawned_count = 0
	var spawn_points = get_children()

	for i in range(spawn_points.size()):
		var marker = spawn_points[i]
		if not marker is Marker2D:
			continue

		# Get unit type from GameController
		var slot_name = "unit_slot%d" % (i + 1)
		var unit_type: String = ""
		if slot_name in GameController:
			unit_type = GameController.get(slot_name)
			# Skip empty slots
			if unit_type == "" or unit_type == "empty" or unit_type == null:
				print("Slot %d empty, skipping" % (i + 1))
				continue
			# Remove .tres if present
			unit_type = unit_type.get_basename()
		else:
			print("Slot %d missing in GameController, skipping" % (i + 1))
			continue

		# Instantiate unit scene
		var unit = unit_scene.instantiate()
		unit.global_position = marker.global_position
		unit.faction = faction
		unit.unit_type = unit_type

		if faction == Marker_Faction.FRIENDLY:
			unit.add_to_group("Friendly_units")
			unit.collision_layer = 1
		else:
			unit.add_to_group("Enemy_units")
			unit.collision_layer = 2

		unit.add_to_group("units")
		add_child(unit)
		spawned_count += 1
		print("Spawned %s at marker %s" % [unit_type, marker.name])

	if spawned_count > 0:
		if faction == Marker_Faction.FRIENDLY:
			call_deferred("emit_signal", "player_units_spawned")
		else:
			call_deferred("emit_signal", "enemy_units_spawned")

# Fallback random unit type picker if needed
func PickUnitType() -> String:
	var num = randi() % 4 + 1
	match num:
		1: return "Archer"
		2: return "Warrior"
		3: return "Knight"
		4: return "Pirate"
	return ""
