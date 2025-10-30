extends Node

enum GamePhase {
	PRE_GAME,
	BUILD,
	FIGHT,
	DEATH,
	POST_GAME
}
@export var Main_scene: String = "res://Scenes/Mainmenu.tscn"
@export var Death_scene: String = "res://Scenes/Gameover.tscn"
@export var build_scene: String = "res://Scenes/Buildscreen.tscn"
@export var fight_scene: String = "res://Scenes/Battlescreen.tscn"
var stats = Stats
var current_phase: GamePhase = GamePhase.PRE_GAME

func _ready():
	Stats.round = 0
	Stats.units_placed = 0
	Stats.units_merged = 0
	Stats.units_lost = 0
	Stats.units_sold = 0
	Stats.units_healed = 0
	Stats.heal_amount_done = 0

func set_phase(new_phase: GamePhase):
	current_phase = new_phase
	print("[GameState] Phase changed to: ", phase_to_string(new_phase))

	# Handle scene change here
	match new_phase:
		GamePhase.PRE_GAME:
			get_tree().change_scene_to_file(Main_scene)
		GamePhase.BUILD:
			get_tree().change_scene_to_file(build_scene)
		GamePhase.FIGHT:
			get_tree().change_scene_to_file(fight_scene)
		GamePhase.DEATH:
			get_tree().change_scene_to_file(Death_scene)
		# You can add other scene changes if needed for DEATH/POST_GAME

func phase_to_string(phase: GamePhase) -> String:
	match phase:
		GamePhase.PRE_GAME:
			clear_run_data()
			return "PRE_GAME"
		GamePhase.BUILD:
			return "BUILD"
		GamePhase.FIGHT:
			return "FIGHT"
		GamePhase.DEATH:
			return "DEATH"
		GamePhase.POST_GAME:
			advance_round()
			set_phase(GamePhase.BUILD)
			return "POST_GAME"
		_:
			return "UNKNOWN"

func advance_round():
	Stats.round += 1
	Stats.wave = int(ceil(Stats.round / 2.0))
	Stats.gold = 8 + (2 * Stats.round)
	Stats.rounds_survived = Stats.round - 1

func clear_run_data():
	Stats.gold = 0
	Stats.round = 0
	Stats.wave = 0
	# Game over stats
	# Gameplay progress
	Stats.time_played = 0.0
	Stats.rounds_survived = 0
	Stats.waves_survived = 0
	# Economy
	Stats.gold_spent = 0
	# Unit management
	Stats.units_placed = 0
	Stats.units_merged = 0
	Stats.units_lost = 0
	Stats.units_sold = 0
	Stats.units_healed = 0
	Stats.heal_amount_done = 0
