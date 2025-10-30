extends Control

@onready var shop1 = get_node("MarginContainer/BottomBar/ShopFrame/GridContainer/Panel7")
@onready var shop2 = get_node("MarginContainer/BottomBar/ShopFrame/GridContainer/Panel8")
@onready var shop3 = get_node("MarginContainer/BottomBar/ShopFrame/GridContainer/Panel9")
@onready var shop4 = get_node("MarginContainer/BottomBar/ShopFrame/GridContainer/Panel10")
@onready var shop_algorithm = preload("res://Game/Shop.gd")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shop1 = shop_algorithm._get_shop_unit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
