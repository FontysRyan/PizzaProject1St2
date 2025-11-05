# Projectile.gd
extends Area2D
class_name Projectile

@onready var sprite = $Sprite2D
var team: String = "player"
var damage: int = 10
var speed: float = 300.0
var target: Unit = null
var direction: Vector2 = Vector2.ZERO

func initialize(projectile_team: String, projectile_damage: int, projectile_speed: float, projectile_target: Unit):
	team = projectile_team
	damage = projectile_damage
	speed = projectile_speed
	target = projectile_target
	
	if team == "enemy":
		sprite.flip_h = true
	
	# Calculate initial direction
	if target:
		direction = (target.position - position).normalized()

func _physics_process(delta):
	if target and not target.is_dead():
		# Homing projectile
		direction = (target.position - position).normalized()
	
	position += direction * speed * delta
	
	# Rotate projectile to face direction
	rotation = direction.angle()
	
	# Remove if off screen
	if position.x < -100 or position.x > 1200 or position.y < -100 or position.y > 700:
		queue_free()

func _on_body_entered(body):
	if body is Unit and body.team != team:
		body.take_damage(damage)
		queue_free()
