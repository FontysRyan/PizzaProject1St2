extends Area2D

@export var speed = 200
@export var lifetime = 5.0
var direction = Vector2.RIGHT  # will be set at spawn
var damage: int
signal hit_target(body)
@export var target: CharacterBody2D
var has_hit = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta):
	#print("Moving: ", direction, " | Speed: ", speed)
	position += direction * speed * delta
	rotation = direction.angle()


func _on_body_entered(body):
	if has_hit:
		return  # already hit something this frame

	if not body.is_in_group("units"):
		return  # ignore non-units

	# --- Case 1: Target still alive and matches the collision ---
	if is_instance_valid(target) and body == target:
		has_hit = true
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
		return

	# --- Case 2: Target is gone (null or freed) ---
	if target == null or not is_instance_valid(target):
		has_hit = true
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
		return
	
func Pickname() -> int:
	var num = randi() % 4 + 1  # 1..4

	return num
	
