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
	for marker in spawn_points:
		var unit_type = PickUnitType()
		if marker is Marker2D:
			#print(marker.name, marker.global_position)
			var unit = unit_scene.instantiate()
			unit.global_position = marker.global_position
			#print("UNIT BELONGS TO FACTION: " , faction)
			unit.faction = faction    # set faction
			unit.unit_type = unit_type     # set unit type
			if faction == 1:
				unit.add_to_group("Friendly_units")
				unit.collision_layer = 1   # Layer: PlayerUnits
				#unit.collision_mask = 2    # Mask: collides with EnemyUnits
			else:
				unit.add_to_group("Enemy_units")
				unit.collision_layer = 2   # Layer: PlayerUnits
				#unit.collision_mask = 1    # Mask: collides with EnemyUnits
			unit.add_to_group("units")
			
			add_child(unit)
			#print("Unit layer:", unit.collision_layer)
			#print("Unit mask:", unit.collision_mask)
			spawned_count += 1
   # Check if we spawned all units
	if spawned_count == units_to_spawn:
		if faction == 1:
			call_deferred("emit_signal", "player_units_spawned")
		elif faction == 2:
			call_deferred("emit_signal", "enemy_units_spawned")
			
func PickUnitType() -> String:
	var num = randi() % 4 + 1  # 1..4
	
	match num:
		1:
			return "Archer"  # example
		2:
			return "Warrior"
		3:
			return "Knight"
		4:
			return "Archer"

	return "" # default fallback
