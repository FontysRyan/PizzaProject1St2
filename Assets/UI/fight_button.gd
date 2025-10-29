extends Button
@export var next_scene: String = "res://Assets/UI/BattleScreen (UI).tscn"

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	print("⚔️ Switching to combat scene...")
	get_tree().change_scene_to_file(next_scene)
