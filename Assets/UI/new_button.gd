extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	GameController.clear_run_data()
	GameController.set_phase(GameController.GamePhase.BUILD)
	GameController.begin_game()
