class_name UnitPanel
extends Resource

@export var unit_name: String
@export var unit_stats: UnitStats
@export var rarity: Rarity

func get_basename() -> String:
	return self.to_string()
