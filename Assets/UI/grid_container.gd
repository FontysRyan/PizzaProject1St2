extends GridContainer

@onready var shop = get_parent()
@onready var tile1: Unit_Panel = $UnitPanel
@onready var tile2: Unit_Panel = $UnitPanel2
@onready var tile3: Unit_Panel = $UnitPanel3
@onready var tile4: Unit_Panel = $UnitPanel4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("test")
	tile1.panel = shop._get_shop_unit()
	tile1._create_panel()
	print("tile1.panel: ", tile1.panel)
	tile2.panel = shop._get_shop_unit()
	tile2._create_panel()
	print("tile2.panel: ", tile2.panel)
	tile3.panel = shop._get_shop_unit()
	tile3._create_panel()
	print("tile3.panel: ", tile3.panel)
	tile4.panel = shop._get_shop_unit()
	tile4._create_panel()
	print("tile4.panel: ", tile4.panel)

	self.add_child(tile1)
	self.add_child(tile2)
	self.add_child(tile3)
	self.add_child(tile4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
