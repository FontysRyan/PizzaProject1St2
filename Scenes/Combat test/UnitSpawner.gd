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
		var unit_type: String = ""
		var unit = unit_scene.instantiate()
		if Stats.units[i] != null:
			var unit_stats: UnitStats = Stats.units[i].panel.unit_stats
			unit_type = Stats.units[i].panel.unit_stats.get_basename()
			if unit_type == "" or unit_type == "empty" or unit_type == null or unit_stats == null:
				print("Slot %d empty, skipping" % (i + 1))
				continue
				# Remove .tres if present
				unit_type = unit_stats.get_basename()
			# Instantiate unit scene
			
			var new_stats: UnitStats = unit_stats.duplicate()
			# Apply buff
			if faction == Marker_Faction.FRIENDLY:
				_apply_buff_to_unit(new_stats, i)

			unit.global_position = marker.global_position
			unit.faction = faction
			unit.unit_type = unit_type
			unit.stats = new_stats  # <-- use the buffed stats here
		else:
			#print("Slot %d missing in GameController, skipping" % (i + 1))
			continue


		if faction == Marker_Faction.FRIENDLY:
			unit.add_to_group("Friendly_units")
			unit.collision_layer = 1
		else:
			unit.add_to_group("Enemy_units")
			unit.collision_layer = 2

		unit.add_to_group("units")
		add_child(unit)
		spawned_count += 1
		#print("Spawned %s at marker %s" % [unit_type, marker.name])

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
	
func _apply_buff_to_unit(unit_stats: UnitStats, slot_index: int) -> void:
	if not ("panel_buffs" in Stats):
		return

	if slot_index >= Stats.panel_buffs.size():
		return

	var buff = Stats.panel_buffs[slot_index]
	if buff == null:
		return

	match buff:
		"ATTACK":
			unit_stats.damage *= 1.25
		"TANKIER":
			unit_stats.max_hp *= 1.5
		"SPEED":
			unit_stats.movement_speed *= 2
		_:
			return

	print("Applied %s buff to unit in slot %d" % [buff, slot_index + 1])
