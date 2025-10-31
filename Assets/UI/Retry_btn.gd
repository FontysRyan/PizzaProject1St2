extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	GameController.clear_run_data()
	GameController.TEMP_clear_build()
	GameController.set_phase(GameController.GamePhase.BUILD)
