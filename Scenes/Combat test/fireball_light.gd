extends Area2D

@export var speed = 400
@export var lifetime = 5.0
var direction = Vector2.RIGHT  # will be set at spawn
signal hit_target(body)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta):
	position += direction * speed * delta
	
	

func _on_body_entered(body):
	# Ignore enemies and non-collisions
	if body.is_in_group("Enemies") or body.is_in_group("Non_collisions"):
		return
	
	# Emit signal instead of just printing
	
	
	# Optional: keep the old print for debugging
	if body.is_in_group("Player"):
		emit_signal("hit_target", body)
		print("YOU DIED BY PAULDRON")
	
	queue_free()
