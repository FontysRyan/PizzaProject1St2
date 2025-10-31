class_name Shop
extends Node

# UnitPanels:
@export var archer = preload("res://Resources/unit panels/Archer.tres")
@export var knight = preload("res://Resources/unit panels/Knight.tres")
@export var melee_hero = preload("res://Resources/unit panels/Melee hero.tres")
@export var paladin = preload("res://Resources/unit panels/Paladin.tres")
@export var pirate_captain = preload("res://Resources/unit panels/Pirate captain.tres")
@export var pirate = preload("res://Resources/unit panels/Pirate.tres")
@export var warrior = preload("res://Resources/unit panels/Warrior.tres")
@export var wizard = preload("res://Resources/unit panels/Wizard.tres")

# Rarities:
@export var common = preload("res://Resources/Rarities/1Common.tres")
@export var rare = preload("res://Resources/Rarities/2Rare.tres")
@export var epic = preload("res://Resources/Rarities/3Epic.tres")
@export var legendary = preload("res://Resources/Rarities/4Legendary.tres")

# List of units
var units = [archer, knight, melee_hero, paladin, pirate_captain, pirate, warrior, wizard]

var rarity: Rarity
var rng = RandomNumberGenerator.new()
var shop_units = []

func _ready() -> void:
	rng.randomize()  # Seed the random number generator
	print("Shop initialized")

func _get_shop_unit() -> UnitPanel:
	rarity = _shop_rarity()
	_shop_units(rarity)
	if shop_units.size() == 0:
		print("No units available for rarity: ", rarity)
		return null
	var tempRandom = rng.randi_range(0, shop_units.size() - 1)
	var unit = shop_units[tempRandom]
	print("Selected unit: ", unit)
	return unit

func _shop_rarity() -> Rarity:
	var tempRandom = rng.randi_range(0, 10000000)
	while tempRandom > 10000:
		tempRandom -= 10000
	if tempRandom < 5000:
		return common
	else: #tempRandom < 8000:
		return rare
	#elif tempRandom < 9500:
		#return epic
	#else:
		#return legendary

func _shop_units(get_rarity: Rarity) -> void:
	shop_units.clear()
	for unit in units:
		if unit.rarity == get_rarity:
			shop_units.append(unit)
	print("Available units for rarity ", get_rarity, ": ", shop_units)


func _on_reroll_button_pressed() -> void:
	pass # Replace with function body.
