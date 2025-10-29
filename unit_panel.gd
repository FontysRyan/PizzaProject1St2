extends Panel

@export var panel: UnitPanel
var unit_level: int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var color = panel.rarity.color
	add_theme_color_override("UnitPanel", color)
	var texture = panel.texture
	get_parent().get_node("SpriteTexture").Texture = texture
	var price = panel.rarity.cost
	get_parent().get_node("PriceLabel").Text = price
	var level = "Lvl: " + str(unit_level)
	get_parent().get_node("LevelLabel").Text = level


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
