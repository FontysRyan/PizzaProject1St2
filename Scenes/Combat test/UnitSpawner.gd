extends Node

@export var unit_scene: PackedScene
func _ready():
	var spawn_points = get_children()
	for marker in spawn_points:
		if marker is Marker2D:
			print(marker.name, marker.global_position)
			var unit = unit_scene.instantiate()
			unit.global_position = marker.global_position
			add_child(unit)
		
