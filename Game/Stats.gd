extends Node

# Active stats
var gold: int = 50
var round: int = 0
var wave: int = 0

# Game over stats
# Gameplay progress
var time_played: float = 0.0
var rounds_survived: int = 0
var waves_survived: int = 0
# Economy
var gold_spent: int = 0
# Unit management
var units_placed: int = 0
var units_merged: int = 0
var units_lost: int = 0
var units_sold: int = 0
var units_healed: int = 0
var heal_amount_done: int = 0

func _next_round():
	round += 1
	rounds_survived += 1

func _next_wave():
	wave += 1
	waves_survived += 1

func _take_gold(price: int):
	gold -= price
	gold_spent += price


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
