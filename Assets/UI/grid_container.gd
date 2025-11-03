extends GridContainer

@onready var shop = get_parent()
@onready var panel_scene = preload("res://unit_panel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roll()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"../../../TopBar/HBoxContainer/GoldLabel".text = str(Stats.gold)

func _on_reroll_button_pressed() -> void:
	if Stats.gold < 1:
		pass
	else:
		Stats._take_gold(1)
		roll()

func roll() -> void:
	# Clear existing panels
	for child in get_children():
		if child is Unit_Panel:
			child.queue_free()

	# Create new panels
	for i in range(4):
		var temp_panel = panel_scene.instantiate()  # Use instantiate() for Godot 4.x
		temp_panel.panel = shop._get_shop_unit()
		temp_panel._fill_panel()
		print("temp_panel.panel: ", temp_panel.panel)
		self.add_child(temp_panel)
