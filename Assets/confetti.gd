extends GPUParticles2D

@onready var confetti: GPUParticles2D = $"."
var stats = Stats

func _ready():
	if stats.round > 1:
		confetti.emitting = true
