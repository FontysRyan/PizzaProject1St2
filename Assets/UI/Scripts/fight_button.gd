extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	GameController.set_phase(GameController.GamePhase.FIGHT)
