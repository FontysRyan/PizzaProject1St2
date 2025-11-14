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

# Helper: safely get a Label node from a NodePath, or null if missing/wrong type.
func get_label(path: NodePath) -> Label:
	if not path or str(path) == "":
		return null
	var node := get_node_or_null(path)
	if node and node is Label:
		return node
	return null



func _ready():
	# assign values (skip if node missing)
	var lbl = get_label(time_played_label_path)
	if lbl:
		lbl.text = str(Stats.time_played if "time_played" in Stats else "Cannot read data")

	lbl = get_label(rounds_survived_label_path)
	if lbl:
		lbl.text = str(Stats.rounds_survived if "rounds_survived" in Stats else "Cannot read data")
	lbl = get_label(waves_survived_label_path)
	if lbl:
		lbl.text = str(Stats.waves_survived if "waves_survived" in Stats else "Cannot read data")

	lbl = get_label(gold_spent_label_path)
	if lbl:
		lbl.text = str(Stats.gold_spent if "gold_spent" in Stats else "Cannot read data")
	lbl = get_label(units_placed_label_path)
	if lbl:
		lbl.text = str(Stats.units_placed if "units_placed" in Stats else "Cannot read data")

	lbl = get_label(units_merged_label_path)
	if lbl:
		lbl.text = str(Stats.units_merged if "units_merged" in Stats else "Cannot read data")
	lbl = get_label(units_lost_label_path)
	if lbl:
		lbl.text = str(Stats.units_lost if "units_lost" in Stats else "Cannot read data")

	lbl = get_label(units_sold_label_path)
	if lbl:
		lbl.text = str(Stats.units_sold if "units_sold" in Stats else "Cannot read data")
	lbl = get_label(units_healed_label_path)
	if lbl:
		lbl.text = str(Stats.units_healed if "units_healed" in Stats else "Cannot read data")

	lbl = get_label(heal_amount_done_label_path)
	if lbl:
		lbl.text = str(Stats.heal_amount_done if "heal_amount_done" in Stats else "Cannot read data")
