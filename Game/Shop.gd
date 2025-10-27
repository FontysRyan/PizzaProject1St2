extends Node

#Rarities:
@onready var common = preload("res://Resources/Rarities/1Common.tres")
@onready var rare = preload("res://Resources/Rarities/2Rare.tres")
@onready var epic = preload("res://Resources/Rarities/3Epic.tres")
@onready var legendary = preload("res://Resources/Rarities/4Legendary.tres")
#UnitPanels:
@onready var archer = preload("res://Resources/unit panels/Archer.tres")
@onready var knight = preload("res://Resources/unit panels/Archer.tres")
@onready var melee_hero = preload("res://Resources/unit panels/Archer.tres")
@onready var paladin = preload("res://Resources/unit panels/Archer.tres")
@onready var pirate_captain = preload("res://Resources/unit panels/Archer.tres")
@onready var pirate = preload("res://Resources/unit panels/Archer.tres")
@onready var warrior = preload("res://Resources/unit panels/Archer.tres")
@onready var wizard = preload("res://Resources/unit panels/Archer.tres")
#list of units
@onready var units = [archer, knight, melee_hero, paladin, pirate_captain, pirate, warrior, wizard]


var rarity: Rarity
var rng = RandomNumberGenerator.new()
var shop_units = [archer, warrior]
var return_unit = null

func _get_shop_unit() -> UnitPanel:
	rarity = _shop_rarity()
	_shop_units(rarity)
	var tempRandom = rng.randf_range(0, float(shop_units.count(UnitPanel)-1))
	#choose what unit
	return shop_units[tempRandom]

func _shop_rarity() -> Rarity:
	var tempRandom = rng.randf_range(0, 10000000)
	#make the random actually random
	while tempRandom > 10000:
		tempRandom -= 10000
	#choose what rarity
	if tempRandom < 5000:
		return common
	elif tempRandom < 8000:
		return rare
	elif tempRandom < 9500:
		return epic
	else:
		return legendary


func _shop_units(get_rarity: Rarity) -> void:
	shop_units.clear()
	for i in units:
		if units[i].rarity == get_rarity:
			shop_units.append(units[i])
