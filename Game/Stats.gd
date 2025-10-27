extends Node

#active stats
var gold
var round
var wave

#game over stats:

#Gameplay Progress:
var time_played
var rounds_survived
var waves_survived
#Economy:
var gold_spent
#Unit Management:
var units_placed
var units_merged
var units_lost
var units_sold
var units_healed
var heal_amount_done

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
