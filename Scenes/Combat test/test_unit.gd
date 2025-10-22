extends RigidBody2D

@export var faction: int = 1  # 1 = default/friendly, 2 = enemy

func _ready():
	var sprite: AnimatedSprite2D = $AnimatedSprite2D

	# Flip sprite based on faction
	match faction:
		1:
			sprite.flip_h = false  # Friendly (faces right)
		2:
			sprite.flip_h = true   # Enemy (faces left)
