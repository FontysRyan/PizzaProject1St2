extends Area2D

@export var speed = 200
@export var lifetime = 5.0
var direction = Vector2.RIGHT  # will be set at spawn
var damage: int
signal hit_target(body)

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
	# Ignore enemies and non-collisions
	#print("I GOT YOU")
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

	if body.is_in_group("units"):
		emit_signal("hit_target", body)
		return
	else:
		queue_free()
	# Emit signal instead of just printing
	
	

	
