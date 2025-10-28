extends Node2D

var units: Array[BaseUnit] = []
var current_turn := 0
var is_turn_running := false

func _ready():
	spawn_units()
	start_battle()

func spawn_units():
	var player = preload("res://testanim/Archer.tscn").instantiate()
	player.position = Vector2(100, 200)
	add_child(player)

	var enemy = preload("res://testanim/Warrior.tscn").instantiate()
	enemy.position = Vector2(400, 200)
	enemy.get_node("AnimatedSprite2D").flip_h = true
	add_child(enemy)

	# Assign targets
	player.target = enemy
	enemy.target = player

	units = [player, enemy]

	for u in units:
		u.attack_finished.connect(_on_attack_finished)

func start_battle():
	if is_turn_running or units.size() < 2:
		return
	is_turn_running = true
	_do_next_attack()

func _do_next_attack():
	if units.size() < 2:
		return

	var attacker = units[current_turn]
	attacker.attack()

func _on_attack_finished(unit: BaseUnit):
	# Switch to the next unit’s turn
	current_turn = (current_turn + 1) % units.size()

	# Small delay between attacks
	await get_tree().create_timer(0.5).timeout

	is_turn_running = false
	start_battle()
