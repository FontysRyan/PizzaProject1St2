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

# ===== UNIT SLOT EXPORTS =====
@export var unit_slot1: String = ""
@export var unit_slot2: String = ""
@export var unit_slot3: String = ""
@export var unit_slot4: String = ""
@export var unit_slot5: String = ""
@export var unit_slot6: String = ""
@export var unit_slot7: String = ""
@export var unit_slot8: String = ""
@export var unit_slot9: String = ""

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
			TEMP_clear_build()
			return "PRE_GAME"
		GamePhase.BUILD:
			return "BUILD"
		GamePhase.FIGHT:
			return "FIGHT"
		GamePhase.DEATH:
			return "DEATH"
			TEMP_clear_build()
		GamePhase.POST_GAME:
			advance_round()
			TEMP_clear_build()
			set_phase(GamePhase.BUILD)
			return "POST_GAME"
		_:
			return "UNKNOWN"

func advance_round():
	Stats.round += 1
	Stats.wave = int(ceil(Stats.round / 2.0))
	Stats.gold = 8 + (2 * Stats.round)
	Stats.rounds_survived = Stats.round - 1
	
func begin_game():
	Stats.round = 1
	Stats.wave = int(ceil(Stats.round / 2.0))
	Stats.gold = 8 + (2 * Stats.round)
func clear_run_data():
	Stats.gold = 0
	Stats.round = 1
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
	


func update_build_slot(slot_index: int, resource_path: String) -> void:
	# Remove ".tres" if present
	var clean_name = resource_path.get_file().get_basename() if resource_path != "" else ""
	
	match slot_index:
		1: unit_slot1 = clean_name
		2: unit_slot2 = clean_name
		3: unit_slot3 = clean_name
		4: unit_slot4 = clean_name
		5: unit_slot5 = clean_name
		6: unit_slot6 = clean_name
		7: unit_slot7 = clean_name
		8: unit_slot8 = clean_name
		9: unit_slot9 = clean_name

	# Debug print
	print("[GameController] Slot", slot_index, "updated to:", clean_name)

# Optional helper to get all slots in a list
func get_build_slots() -> Array:
	return [
		unit_slot1, unit_slot2, unit_slot3,
		unit_slot4, unit_slot5, unit_slot6,
		unit_slot7, unit_slot8, unit_slot9
	]
	
func TEMP_clear_build():
	unit_slot1 = ""
	unit_slot2 = ""
	unit_slot3 = ""
	unit_slot4 = ""
	unit_slot5 = ""
	unit_slot6 = ""
	unit_slot7 = ""
	unit_slot8 = ""
	unit_slot9 = ""

func set_game_speed(scale: float) -> void:
	# Clamp to prevent negative or absurd values
	Engine.time_scale = clamp(scale, 0.0, 10.0)
	print("Game speed set to:", Engine.time_scale)
