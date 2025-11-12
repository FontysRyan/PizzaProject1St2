extends Button


func _ready():
	if !Stats.running:
		self.disabled = true
	pressed.connect(_on_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_pressed():
	GameController.set_phase(GameController.GamePhase.BUILD)
