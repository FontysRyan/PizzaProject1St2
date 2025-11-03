# Camera2DShake.gd
extends Camera2D

@export var shake_decay: float = 3.0
@export var max_offset: Vector2 = Vector2(10, 5)
@export var max_roll: float = 0.1

var trauma: float = 0.0
var trauma_power: int = 2
var noise: FastNoiseLite
var noise_y: float = 0.0

func _ready():
	# Create noise for smooth shake
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.5

func _process(delta):
	if trauma > 0:
		trauma = max(trauma - shake_decay * delta, 0)
		shake()

func shake_camera(duration: float = 0.3, intensity: float = 8.0):
	trauma = min(trauma + intensity * 0.01, 1.0)
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		trauma = 0.0
		reset_camera()

func shake():
	var amount = pow(trauma, trauma_power)
	
	# Rotational shake
	rotation = max_roll * amount * randf_range(-1, 1)
	
	# Positional shake using noise for smooth movement
	noise_y += 1.0
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 2, noise_y)

func reset_camera():
	offset = Vector2.ZERO
	rotation = 0.0
