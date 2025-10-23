extends Node2D

enum Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Faction = Faction.FRIENDLY

func _ready():
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	var ring1: Sprite2D = $faction_Ring1
	var ring2: Sprite2D = $faction_Ring2

	# Flip the unit if it's an enemy
	sprite.flip_h = (faction == Faction.ENEMY)

	# Show correct faction ring
	ring1.visible = (faction == Faction.FRIENDLY)
	ring2.visible = (faction == Faction.ENEMY)
