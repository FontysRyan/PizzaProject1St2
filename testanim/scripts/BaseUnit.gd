class_name BaseUnit
extends Node2D

@export var is_player := true

func _ready():
	play_state(State.IDLE)
	_create_team_circle()

func _create_team_circle():
	var color: Color
	if is_player:
		color = Color(0.3, 0.6, 1.0, 0.6)  # Blue for player
	else:
		color = Color(1.0, 0.3, 0.3, 0.6)  # Red for enemy
	draw_circle(Vector2(0, 12), 10, color)
	
signal attack_started(unit)
signal attack_finished(unit)
signal took_hit(unit, damage)

enum State { IDLE, RUN, ATTACK, HIT, DEAD }

@export var speed := 40.0
@export var health := 100
var target: BaseUnit
var can_attack := true
var is_dead := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func play_state(state: State):
	match state:
		State.IDLE:
			sprite.play("idle")
		State.RUN:
			sprite.play("run")
		State.ATTACK:
			sprite.play("attack")
		State.HIT:
			sprite.play("hit")
		State.DEAD:
			sprite.play("dead")

func take_hit(damage: int):
	if is_dead:
		return

	health -= damage
	play_state(State.HIT)
	emit_signal("took_hit", self, damage)

	if health <= 0:
		is_dead = true
		play_state(State.DEAD)
	else:
		await sprite.animation_finished
		play_state(State.IDLE)
