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
var current_phase: GamePhase = GamePhase.PRE_GAME

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
