extends Node2D

enum Faction { FRIENDLY = 1, ENEMY = 2 }
@export var faction: Faction = Faction.FRIENDLY
@export var stats: UnitStats #script
@export var unit_type: String = "Archer"
var Unit_in_Battle: bool = false
@export var target: Node2D = null  # the unit’s current target


func _ready():
	# Load stats if none assigned
	if faction == 1:
		name = "Player_unit"
	else:
		name = "Enemy_unit"
	if stats == null:
		var path = "res://Resources/units/%s.tres" % unit_type
		var res = load(path)
		if res and res is UnitStats:
			stats = res
		else:
			push_warning("UnitStats resource not found at %s" % path)

	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	var ring1: Sprite2D = $faction_Ring1
	var ring2: Sprite2D = $faction_Ring2

	# Flip the unit if it's an enemy
	sprite.flip_h = (faction == Faction.ENEMY)

	# Show correct faction ring
	ring1.visible = (faction == Faction.FRIENDLY)
	ring2.visible = (faction == Faction.ENEMY)

	# Connect to battle start
	var combat_system_node = get_tree().get_current_scene()
	if combat_system_node:
		var combat_system = combat_system_node as CombatSystem  # cast to your script type
		if combat_system:
			if combat_system.Battle_has_begun:
				_on_battle_start()
			else:
				set_process(true)  # start polling in _process()


func _process(delta):
	var combat_system_node = get_tree().get_current_scene()
	if combat_system_node:
		var combat_system = combat_system_node as CombatSystem
		if combat_system and combat_system.Battle_has_begun:
			_on_battle_start()
			set_process(false)  # stop checking after battle starts


func _on_battle_start():
	print(name, " battle has started!")
	Unit_in_Battle = true
	_choose_target()
	# Enable AI, start moving/attacking, etc.
	
func _choose_target():
	var enemies := []
	for unit in get_tree().get_nodes_in_group("units"):
		if unit == self:
			continue
		if unit.faction != faction:
			enemies.append(unit)

	if enemies.is_empty():
		target = null
		return

	var nearest_target: Node2D = enemies[0]
	var nearest_dist := global_position.distance_to(nearest_target.global_position)

	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_target = enemy

	target = nearest_target
	if target:
		print(name, " is targeting ", target.name)
