extends GPUParticles2D

@onready var confetti: GPUParticles2D = $"."

func _ready():
	if Stats.round > 1:
		confetti.emitting = true
