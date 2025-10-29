extends Button

@export var QuitButton_path: NodePath = NodePath()
var QuitButton: Button = null

func _ready() -> void:
	if QuitButton_path != NodePath():
		QuitButton = get_node_or_null(QuitButton_path) as Button
	else:
		QuitButton = self
	if QuitButton:
		QuitButton.pressed.connect(Callable(self, "_on_quit_pressed"))

func _on_quit_pressed() -> void:
	get_tree().quit()
