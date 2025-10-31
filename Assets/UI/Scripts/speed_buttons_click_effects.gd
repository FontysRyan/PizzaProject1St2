extends HBoxContainer

@export var play_button_path: NodePath
@export var pause_button_path: NodePath
@export var fast_forward_button_path: NodePath

var play_button: TextureButton
var pause_button: TextureButton
var fast_forward_button: TextureButton

var active_button: TextureButton = null
var tweens: Dictionary = {}               # btn -> Tween
var original_colors: Dictionary = {}      # btn -> Color
const ACTIVE_COLOR := Color(0.0, 1.4, 1.0, 1.0)

func _ready() -> void:
	for btn_path in [play_button_path, pause_button_path, fast_forward_button_path]:
		var btn: TextureButton = get_node_or_null(btn_path)
		if btn:
			if btn.has_method("get_modulate"):
				original_colors[btn] = btn.modulate
			btn.gui_input.connect(_on_button_gui_input.bind(btn))

	play_button = get_node_or_null(play_button_path)
	pause_button = get_node_or_null(pause_button_path)
	fast_forward_button = get_node_or_null(fast_forward_button_path)

	if play_button:
		active_button = play_button
		_update_button_colors()

func _on_button_gui_input(event: InputEvent, btn: TextureButton) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			animate_press(btn)
			match btn:
				play_button:
					# TODO: handle play button press
					GameController.set_game_speed(1)
					pass
				pause_button:
					# TODO: handle pause button press
					GameController.set_game_speed(0)
					pass
				fast_forward_button:
					# TODO: handle fast forward button press
					GameController.set_game_speed(5)
					pass
				_:
					# Unknown button (fallback)
					pass
		else:
			animate_release(btn)

func _kill_tween(btn: TextureButton) -> void:
	if tweens.has(btn) and is_instance_valid(tweens[btn]):
		tweens[btn].kill()
	tweens.erase(btn)

func animate_press(btn: TextureButton) -> void:
	_kill_tween(btn)
	var t := create_tween()
	tweens[btn] = t
	t.tween_property(btn, "scale", btn.scale * 0.92, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(btn, "modulate", Color(0.9, 0.9, 0.9), 0.06)
	t.finished.connect(_on_tween_finished.bind(btn))

func animate_release(btn: TextureButton) -> void:
	_kill_tween(btn)
	active_button = btn
	_update_button_colors()

	var t := create_tween()
	tweens[btn] = t
	t.tween_property(btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	t.tween_property(btn, "modulate", _target_color(btn), 0.12)
	t.finished.connect(_on_tween_finished.bind(btn))

func _on_tween_finished(btn: TextureButton) -> void:
	tweens.erase(btn)

func simulate_click(btn: TextureButton) -> void:
	animate_press(btn)
	await get_tree().create_timer(0.12).timeout
	animate_release(btn)

# ---- Helpers ----

func _target_color(btn: TextureButton) -> Color:
	return ACTIVE_COLOR if btn == active_button else original_colors.get(btn, Color.WHITE)

func _update_button_colors() -> void:
	for btn in [play_button, pause_button, fast_forward_button]:
		if btn:
			btn.modulate = _target_color(btn)
