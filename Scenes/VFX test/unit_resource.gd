# unit_resource.gd
extends Resource
class_name UnitResource

@export_category("Combat Stats")
@export var unit_name: String = ""
@export var health: int = 100
@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var attack_range: float = 50.0
@export var move_speed: int = 100

@export_category("Visual Properties")
@export var sprite_frames: SpriteFrames
@export var scale: Vector2 = Vector2(1, 1)

@export_category("Projectile Settings")
@export var has_projectile: bool = false
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 300.0
@export var projectile_offset: Vector2 = Vector2(20, 0)

@export_category("Animation Names")
@export var idle_anim: String = "idle"
@export var run_anim: String = "run"
@export var attack_anim: String = "attack"
@export var hit_anim: String = "hit"
@export var dead_anim: String = "dead"
