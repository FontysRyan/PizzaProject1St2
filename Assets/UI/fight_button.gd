extends Button
@export var next_scene: String = "res://Assets/UI/BattleScreen (UI).tscn"

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	GameController.set_phase(GameController.GamePhase.FIGHT)
