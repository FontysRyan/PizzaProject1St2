extends Node2D
class_name CombatSystem  
var player_units_spawned: bool = false
var enemy_units_spawned: bool = false
var Battle_has_begun: bool = false

func _ready():
	var player_spawner = $PlayerSpawner
	var enemy_spawner = $EnemySpawner
	player_spawner.connect("player_units_spawned", Callable(self, "_on_player_units_spawned"))
	print("Connected PlayerSpawner signal")
	enemy_spawner.connect("enemy_units_spawned", Callable(self, "_on_enemy_units_spawned"))
	print("Connected EnemySpawner signal")
func _on_enemy_units_spawned() -> void:
	enemy_units_spawned = true;
	print("Enemy units ready")
	checkUnitFaction_readyness()

func _on_player_units_spawned() -> void:
	player_units_spawned = true;
	print("Player units ready")
	checkUnitFaction_readyness()

func checkUnitFaction_readyness():
	if player_units_spawned == true && enemy_units_spawned == true:
		print("🔥 Both sides ready — battle begins!")
		Battle_has_begun = true
