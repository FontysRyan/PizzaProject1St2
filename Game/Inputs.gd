extends Node


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		get_tree().paused = !get_tree().paused
