extends Node

enum GamePhase {
	PRE_GAME,
	BUILD,
	FIGHT,
	DEATH,
	POST_GAME,
	MID_GAME
}
@export var Main_scene: String = "res://Scenes/Mainmenu.tscn"
@export var Death_scene: String = "res://Scenes/Gameover.tscn"
@export var build_scene: String = "res://Scenes/Buildscreen.tscn"
@export var fight_scene: String = "res://Scenes/Battlescreen.tscn"
var current_phase: GamePhase = GamePhase.PRE_GAME

# ===== UNIT SLOT EXPORTS =====
@export var unit_slot1: Unit_Panel = null
@export var unit_slot2: Unit_Panel = null
@export var unit_slot3: Unit_Panel = null
@export var unit_slot4: Unit_Panel = null
@export var unit_slot5: Unit_Panel = null
@export var unit_slot6: Unit_Panel = null
@export var unit_slot7: Unit_Panel = null
@export var unit_slot8: Unit_Panel = null
@export var unit_slot9: Unit_Panel = null

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
			get_tree().paused = false
		GamePhase.BUILD:
			get_tree().change_scene_to_file(build_scene)
		GamePhase.FIGHT:
			Stats.units = get_build_slots()
			var board_node = get_tree().get_root().find_child("Board", true, false)
			if board_node and board_node.has_method("export_buffs_to_stats"):
				board_node.export_buffs_to_stats()
			get_tree().change_scene_to_file(fight_scene)
		GamePhase.DEATH:
			Stats.units.clear()
			get_tree().change_scene_to_file(Death_scene)
		GamePhase.MID_GAME:
			Stats.units = get_build_slots()
			get_tree().change_scene_to_file(Main_scene)
			get_tree().paused = false
		# You can add other scene changes if needed for DEATH/POST_GAME

func phase_to_string(phase: GamePhase) -> String:
	match phase:
		GamePhase.PRE_GAME:
			set_game_speed(1)
			clear_run_data()
			return "PRE_GAME"
		GamePhase.BUILD:
			return "BUILD"
		GamePhase.FIGHT:
			return "FIGHT"
		GamePhase.DEATH:
			set_game_speed(1)
			return "DEATH"
		GamePhase.POST_GAME:
			set_game_speed(1)
			advance_round()
			set_phase(GamePhase.BUILD)
			return "POST_GAME"
		GamePhase.MID_GAME:
			set_game_speed(1)
			return "MID_GAME"
		_:
			return "UNKNOWN"

func advance_round():
	Stats.round += 1
	Stats.waves_in_round = int(ceil(Stats.round / 2.0))
	Stats.gold = 8 + (2 * Stats.round)
	Stats.rounds_survived = Stats.round - 1
#func advance_wave():
	#if Stats.wave != Stats.waves_in_round:
		#Stats.wave += 1
	#else:
		#set_phase(GamePhase.POST_GAME)
func begin_game():
	Stats.running = true
	Stats.round = 1
	Stats.waves_in_round = int(ceil(Stats.round / 2.0))
	Stats.gold = 8 + (2 * Stats.round)
	Stats.wave = 1
	run_timer.start()
func clear_run_data():
	Stats.running = false
	Stats.units.clear()
	clear_build()
	Stats.gold = 0
	Stats.round = 1
	Stats.wave = 1
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


func update_build_slot(slot_index: int, resource_path: Unit_Panel) -> void:
	# Remove ".tres" if present
	var clean_name = resource_path if resource_path != null else null
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

# Optional helper to get all slots in a list
func get_build_slots() -> Array:
	return [
		unit_slot1, unit_slot2, unit_slot3,
		unit_slot4, unit_slot5, unit_slot6,
		unit_slot7, unit_slot8, unit_slot9
	]

func clear_build_slot(slot_index: int) -> void:
	match slot_index:
		1: unit_slot1 = null
		2: unit_slot2 = null
		3: unit_slot3 = null
		4: unit_slot4 = null
		5: unit_slot5 = null
		6: unit_slot6 = null
		7: unit_slot7 = null
		8: unit_slot8 = null
		9: unit_slot9 = null

func get_unit_slot(slot_index: int) -> Unit_Panel:
	match slot_index:
		1: return unit_slot1
		2: return unit_slot2
		3: return unit_slot3
		4: return unit_slot4
		5: return unit_slot5
		6: return unit_slot6
		7: return unit_slot7
		8: return unit_slot8
		9: return unit_slot9
		_: return null

func clear_build() -> void:
	unit_slot1 = null
	unit_slot2 = null
	unit_slot3 = null
	unit_slot4 = null
	unit_slot5 = null
	unit_slot6 = null
	unit_slot7 = null
	unit_slot8 = null
	unit_slot9 = null

func set_game_speed(scale: float) -> void:
	# Clamp to prevent negative or absurd values
	Engine.time_scale = clamp(scale, 0.0, 10.0)
	print("Game speed set to:", Engine.time_scale)
