extends Control

@export var time_played_label_path: NodePath
@export var rounds_survived_label_path: NodePath
@export var waves_survived_label_path: NodePath

@export var gold_spent_label_path: NodePath

@export var units_placed_label_path: NodePath
@export var units_merged_label_path: NodePath
@export var units_lost_label_path: NodePath
@export var units_sold_label_path: NodePath

@export var units_healed_label_path: NodePath
@export var heal_amount_done_label_path: NodePath

const StatsScript = preload("res://Game/Stats.gd")
var stats

# Helper: safely get a Label node from a NodePath, or null if missing/wrong type.
func get_label(path: NodePath) -> Label:
	if not path or str(path) == "":
		return null
	var node := get_node_or_null(path)
	if node and node is Label:
		return node
	return null



func _ready():
	stats = get_node("/root/Stats")  # uses the already-running singleton instance


	# assign values (skip if node missing)
	var lbl = get_label(time_played_label_path)
	if lbl:
		lbl.text = str(stats.time_played if "time_played" in stats else "Cannot read data")

	lbl = get_label(rounds_survived_label_path)
	if lbl:
		lbl.text = str(stats.rounds_survived if "rounds_survived" in stats else "Cannot read data")
	lbl = get_label(waves_survived_label_path)
	if lbl:
		lbl.text = str(stats.waves_survived if "waves_survived" in stats else "Cannot read data")

	lbl = get_label(gold_spent_label_path)
	if lbl:
		lbl.text = str(stats.gold_spent if "gold_spent" in stats else "Cannot read data")
	lbl = get_label(units_placed_label_path)
	if lbl:
		lbl.text = str(stats.units_placed if "units_placed" in stats else "Cannot read data")

	lbl = get_label(units_merged_label_path)
	if lbl:
		lbl.text = str(stats.units_merged if "units_merged" in stats else "Cannot read data")
	lbl = get_label(units_lost_label_path)
	if lbl:
		lbl.text = str(stats.units_lost if "units_lost" in stats else "Cannot read data")

	lbl = get_label(units_sold_label_path)
	if lbl:
		lbl.text = str(stats.units_sold if "units_sold" in stats else "Cannot read data")
	lbl = get_label(units_healed_label_path)
	if lbl:
		lbl.text = str(stats.units_healed if "units_healed" in stats else "Cannot read data")

	lbl = get_label(heal_amount_done_label_path)
	if lbl:
		lbl.text = str(stats.heal_amount_done if "heal_amount_done" in stats else "Cannot read data")
