extends Node

@export var unit_scene: PackedScene
enum Marker_Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Marker_Faction
func _ready():
	var spawn_points = get_children()
	for marker in spawn_points:
		if marker is Marker2D:
			print(marker.name, marker.global_position)
			var unit = unit_scene.instantiate()
			unit.global_position = marker.global_position
			unit.faction = faction    # set faction
			unit.unit_type = "Archer"           # set unit type
			add_child(unit)
		
