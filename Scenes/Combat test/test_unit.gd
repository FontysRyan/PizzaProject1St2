extends Node2D

enum Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Faction = Faction.FRIENDLY
@export var stats: UnitStats #script
@export var unit_type: String = "Archer"



func _ready():
	# Load stats if none assigned
	if stats == null:
		var path = "res://Resources/units/%s.tres" % unit_type
		var res = load(path)
		if res and res is UnitStats:
			stats = res
		else:
			push_warning("UnitStats resource not found at %s" % path)

	print(stats.description if stats else "No stats loaded")
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	var ring1: Sprite2D = $faction_Ring1
	var ring2: Sprite2D = $faction_Ring2


	# Flip the unit if it's an enemy
	sprite.flip_h = (faction == Faction.ENEMY)

	# Show correct faction ring
	ring1.visible = (faction == Faction.FRIENDLY)
	ring2.visible = (faction == Faction.ENEMY)
		
