class_name UnitStats
extends Resource

#Character sprite
@export var texture: Texture2D

#Stats
@export var type: String = ""
@export var description: String = ""
@export var max_hp: float = 25.0
@export var attack_speed: float = 2.0
@export var attack_amount: int = 1
@export var movement_speed: float = 5.0
@export var damage: float = 10.0
@export var crit_chance: float = 25.0
@export var crit_modifier: float = 50.0
@export var range: float = 50.0
@export var ability_type: Ability
