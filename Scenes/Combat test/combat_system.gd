extends Node2D
class_name CombatSystem  

var player_units_spawned: bool = false
var enemy_units_spawned: bool = false
var Battle_has_begun: bool = false
@export var player_spawner: Node
@export var enemy_spawner: Node

func _ready():
	player_spawner.connect("player_units_spawned", Callable(self, "_on_player_units_spawned"))
	print("Connected PlayerSpawner signal")
	enemy_spawner.connect("enemy_units_spawned", Callable(self, "_on_enemy_units_spawned"))
	print("Connected EnemySpawner signal")
	
	
func _process(delta):
	if Battle_has_begun:
		check_battle_end()

func _on_enemy_units_spawned() -> void:
	enemy_units_spawned = true
	print("Enemy units ready")
	checkUnitFaction_readyness()

func _on_player_units_spawned() -> void:
	player_units_spawned = true
	print("Player units ready")
	checkUnitFaction_readyness()

func checkUnitFaction_readyness():
	if player_units_spawned and enemy_units_spawned:
		print("🔥 Both sides ready — battle begins!")
		Battle_has_begun = true

func check_battle_end():
	var friendly_alive = get_tree().get_nodes_in_group("Friendly_units").size() > 0
	var enemy_alive = get_tree().get_nodes_in_group("Enemy_units").size() > 0
	
	if not friendly_alive:
		#rint("Player lost!")
		Battle_has_begun = false
		await get_tree().create_timer(1).timeout
		GameController.set_phase(GameController.GamePhase.DEATH)
	elif not enemy_alive:
		#print("Player won!")
		if(Stats.wave == Stats.waves_in_round):
			Battle_has_begun = false
			await get_tree().create_timer(1).timeout
			GameController.set_phase(GameController.GamePhase.POST_GAME)
		else: 
			print("⭕-Round ", Stats.round, ": Player defeated wave: ", Stats.wave , " of ", Stats.waves_in_round)
			Stats.wave += 1
			enemy_spawner.enemy_wave_incoming()
