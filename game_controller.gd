extends Node

enum GamePhase {
	PRE_GAME,
	BUILD,
	FIGHT,
	DEATH,
	POST_GAME
}

@export var build_scene: String = "res://Assets/UI/BuildScreen (UI).tscn"
@export var fight_scene: String = "res://Assets/UI/BattleScreen (UI).tscn"
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
		GamePhase.BUILD:
			get_tree().change_scene_to_file(build_scene)
		GamePhase.FIGHT:
			get_tree().change_scene_to_file(fight_scene)
		# You can add other scene changes if needed for DEATH/POST_GAME

func phase_to_string(phase: GamePhase) -> String:
	match phase:
		GamePhase.PRE_GAME:
			return "PRE_GAME"
		GamePhase.BUILD:
			return "BUILD"
		GamePhase.FIGHT:
			return "FIGHT"
		GamePhase.DEATH:
			return "DEATH"
		GamePhase.POST_GAME:
			return "POST_GAME"
		_:
			return "UNKNOWN"

func advance_round():
	Stats.round = 1
	Stats.wave = int(ceil(Stats.round / 2.0))
	Stats.gold = 8 + (2 * Stats.round)
	Stats.rounds_survived = Stats.round - 1
