# TestSpace.gd
extends Node2D

@onready var player_spawn = $SpawnAreas/PlayerSpawnArea
@onready var enemy_spawn = $SpawnAreas/EnemySpawnArea
@onready var units_container = $Units
@onready var projectiles_container = $Projectiles
@onready var ui = $UI
@onready var unit_selection_container = $UI/UnitSelection
@onready var battle_info = $UI/BattleInfo
@onready var spawn_controls = $UI/SpawnControls

# Reference to the UI buttons
@onready var spawn_player_btn = $UI/SpawnControls/SpawnPlayerBtn
@onready var spawn_enemy_btn = $UI/SpawnControls/SpawnEnemyBtn
@onready var clear_all_btn = $UI/SpawnControls/ClearAllBtn
@onready var restart_btn = $UI/SpawnControls/RestartBtn
@onready var randomize_btn = $UI/SpawnControls/RandomizeBtn

@export var unit_resources: Array[UnitResource] = []
@export var starting_units_per_side: int = 4
@export var max_units_per_side: int = 8

var selected_unit_index: int = 0
var battle_started: bool = false
var formation_positions: Dictionary = {}

# Add to TestSpace.gd
@onready var camera: Camera2D = $Camera2D

func _ready():
	# Wait for all nodes to be ready
	await get_tree().process_frame
	
	# Make sure camera is current
	if camera:
		camera.make_current()
		camera.add_to_group("camera")
	else:
		push_warning("No camera found in scene - camera shake won't work")
	
	setup_ui()
	setup_formations()
	start_battle()


func show_error_message():
	var error_label = Label.new()
	error_label.text = "ERROR: No unit resources assigned!\nPlease assign unit resources in the inspector."
	error_label.add_theme_color_override("font_color", Color.RED)
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(error_label)
	error_label.position = Vector2(200, 200)

func start_battle():
	if unit_resources.size() == 0:
		push_error("Cannot start battle: No unit resources assigned")
		return
		
	battle_started = true
	spawn_initial_armies()
	update_battle_info()

func setup_formations():
	# Player formation positions (2 rows, 4 columns)
	var player_positions = []
	
	for row in range(2):
		for col in range(4):
			var x = player_spawn.position.x + 40 + (col * 40)
			var y = player_spawn.position.y + 60 + (row * 60)
			player_positions.append(Vector2(x, y))
	
	# Enemy formation positions (mirrored)
	var enemy_positions = []
	for row in range(2):
		for col in range(4):
			var x = enemy_spawn.position.x - 40 - (col * 40)
			var y = enemy_spawn.position.y + 60 + (row * 60)
			enemy_positions.append(Vector2(x, y))
	
	formation_positions = {
		"player": player_positions,
		"enemy": enemy_positions
	}

func spawn_initial_armies():
	clear_all_units()
	
	# Safety check
	if unit_resources.size() == 0:
		push_error("Cannot spawn armies: No unit resources")
		return
	
	# Spawn balanced teams with formations
	var player_units = get_random_unit_selection(starting_units_per_side)
	var enemy_units = get_random_unit_selection(starting_units_per_side)
	
	for i in range(player_units.size()):
		spawn_unit_in_formation(player_units[i], "player", i)
	
	for i in range(enemy_units.size()):
		spawn_unit_in_formation(enemy_units[i], "enemy", i)

func get_random_unit_selection(count: int) -> Array:
	var selection = []
	
	# Safety check - if no unit resources, return empty array
	if unit_resources.size() == 0:
		return selection
	
	for i in range(count):
		var random_index = randi() % unit_resources.size()
		selection.append(random_index)
	return selection

func spawn_unit_in_formation(unit_index: int, team: String, formation_index: int):
	if unit_index >= unit_resources.size():
		push_error("Invalid unit index: " + str(unit_index))
		return
		
	var unit_scene = preload("res://Scenes/VFX test/unit_test.tscn")
	var unit = unit_scene.instantiate()
	
	# Add unit to scene first, then initialize
	units_container.add_child(unit)
	
	# Get formation position
	var spawn_position = get_formation_position(team, formation_index)
	unit.initialize(unit_resources[unit_index], team, spawn_position)
	unit.add_to_group("units")

func get_formation_position(team: String, index: int) -> Vector2:
	var positions = formation_positions.get(team, [])
	if index < positions.size():
		return positions[index]
	else:
		# Fallback to random position in spawn area
		return get_random_spawn_position(team)

func get_random_spawn_position(team: String) -> Vector2:
	var spawn_rect: Rect2
	if team == "player":
		spawn_rect = Rect2(player_spawn.position, player_spawn.size)
	else:
		spawn_rect = Rect2(enemy_spawn.position, enemy_spawn.size)
	
	return Vector2(
		randf_range(spawn_rect.position.x, spawn_rect.end.x),
		randf_range(spawn_rect.position.y, spawn_rect.end.y)
	)

func setup_ui():
	# Safety check - make sure the UI node exists
	if not ui or not unit_selection_container:
		push_error("UI nodes not found! Check your scene structure.")
		return
	
	# Clear existing buttons safely
	if unit_selection_container.get_child_count() > 0:
		for child in unit_selection_container.get_children():
			child.queue_free()
	
	# Safety check for unit resources
	if unit_resources.size() == 0:
		var error_label = Label.new()
		error_label.text = "No unit resources assigned"
		error_label.add_theme_color_override("font_color", Color.RED)
		unit_selection_container.add_child(error_label)
		return
	
	# Create unit selection buttons
	for i in range(unit_resources.size()):
		var button = TextureButton.new()
		
		# Get first frame of idle animation for preview
		if unit_resources[i] and unit_resources[i].sprite_frames:
			var texture = unit_resources[i].sprite_frames.get_frame_texture("idle", 0)
			if texture:
				button.texture_normal = texture
		
		button.custom_minimum_size = Vector2(64, 64)
		button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		
		# Set tooltip text safely
		var unit_name = unit_resources[i].unit_name if unit_resources[i] else "Unknown Unit"
		button.tooltip_text = unit_name
		button.pressed.connect(_on_unit_selected.bind(i))
		
		# Add label with unit name
		var label = Label.new()
		label.text = unit_name
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 2)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		
		var container = VBoxContainer.new()
		container.add_child(button)
		container.add_child(label)
		
		unit_selection_container.add_child(container)
	
	# Connect control buttons if they exist
	connect_control_buttons()
	
	# Select first unit by default
	if unit_resources.size() > 0:
		_on_unit_selected(0)

func connect_control_buttons():
	# Connect the spawn control buttons
	if spawn_player_btn:
		if not spawn_player_btn.is_connected("pressed", _on_spawn_player_pressed):
			spawn_player_btn.pressed.connect(_on_spawn_player_pressed)
	
	if spawn_enemy_btn:
		if not spawn_enemy_btn.is_connected("pressed", _on_spawn_enemy_pressed):
			spawn_enemy_btn.pressed.connect(_on_spawn_enemy_pressed)
	
	if clear_all_btn:
		if not clear_all_btn.is_connected("pressed", _on_clear_all_pressed):
			clear_all_btn.pressed.connect(_on_clear_all_pressed)
	
	if restart_btn:
		if not restart_btn.is_connected("pressed", _on_restart_battle_pressed):
			restart_btn.pressed.connect(_on_restart_battle_pressed)
	
	if randomize_btn:
		if not randomize_btn.is_connected("pressed", _on_randomize_teams_pressed):
			randomize_btn.pressed.connect(_on_randomize_teams_pressed)

func _on_unit_selected(index: int):
	if index >= unit_resources.size():
		push_error("Invalid unit selection index: " + str(index))
		return
		
	selected_unit_index = index
	# Visual feedback for selection
	for i in range(unit_selection_container.get_child_count()):
		var container = unit_selection_container.get_child(i)
		var button = container.get_child(0)
		if button is TextureButton:
			button.modulate = Color.WHITE if i != index else Color.YELLOW

func clear_all_units():
	# Safety check for units container
	if units_container:
		for unit in units_container.get_children():
			unit.queue_free()
	
	# Safety check for projectiles container
	if projectiles_container:
		for projectile in projectiles_container.get_children():
			projectile.queue_free()
	
	update_battle_info()

func get_unit_count(team: String) -> int:
	var count = 0
	if units_container:
		for unit in units_container.get_children():
			if unit.has_method("is_dead") and unit.has_method("get_team"):
				if unit.get_team() == team and not unit.is_dead():
					count += 1
	return count

func update_battle_info():
	if not battle_info:
		return
		
	var player_count = get_unit_count("player")
	var enemy_count = get_unit_count("enemy")
	
	var player_count_label = battle_info.get_node("PlayerCount") as Label
	var enemy_count_label = battle_info.get_node("EnemyCount") as Label
	var battle_status_label = battle_info.get_node("BattleStatus") as Label
	
	if player_count_label:
		player_count_label.text = "Player: " + str(player_count)
	if enemy_count_label:
		enemy_count_label.text = "Enemy: " + str(enemy_count)
	
	# Check for battle end
	if battle_started and battle_status_label:
		if player_count == 0:
			battle_status_label.text = "ENEMY WINS!"
			battle_status_label.add_theme_color_override("font_color", Color.RED)
		elif enemy_count == 0:
			battle_status_label.text = "PLAYER WINS!"
			battle_status_label.add_theme_color_override("font_color", Color.GREEN)
		else:
			battle_status_label.text = "BATTLE IN PROGRESS!"
			battle_status_label.add_theme_color_override("font_color", Color.WHITE)

# UI Signal Handlers - Make sure these are connected in the editor or via code
func _on_spawn_player_pressed():
	print("Spawn Player button pressed!")
	if unit_resources.size() == 0:
		push_error("Cannot spawn unit: No unit resources assigned")
		return
		
	if get_unit_count("player") < max_units_per_side:
		spawn_unit_in_formation(selected_unit_index, "player", get_unit_count("player"))
		update_battle_info()

func _on_spawn_enemy_pressed():
	print("Spawn Enemy button pressed!")
	if unit_resources.size() == 0:
		push_error("Cannot spawn unit: No unit resources assigned")
		return
		
	if get_unit_count("enemy") < max_units_per_side:
		spawn_unit_in_formation(selected_unit_index, "enemy", get_unit_count("enemy"))
		update_battle_info()

func _on_clear_all_pressed():
	print("Clear All button pressed!")
	clear_all_units()

func _on_restart_battle_pressed():
	print("Restart Battle button pressed!")
	start_battle()

func _on_randomize_teams_pressed():
	print("Randomize Teams button pressed!")
	spawn_initial_armies()
