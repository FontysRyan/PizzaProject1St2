extends Button

@export var popup_path: NodePath
@export var YesButton_path: NodePath
@export var NoButton_path: NodePath
@export var canvaslayer_path: NodePath
var popup: Node = null
var YesButton: Button = null
var NoButton: Button = null
var canvaslayer: Node = null

func _ready():
	if popup_path != null and has_node(popup_path):
		popup = get_node(popup_path)
	if YesButton_path != null and has_node(YesButton_path):
		YesButton = get_node(YesButton_path) as Button
		if YesButton:
			YesButton.connect("pressed", Callable(self, "_on_yes_pressed"))
	if NoButton_path != null and has_node(NoButton_path):
		NoButton = get_node(NoButton_path) as Button
		if NoButton:
			NoButton.connect("pressed", Callable(self, "_on_no_pressed"))
	if canvaslayer_path != null and has_node(canvaslayer_path):
		canvaslayer = get_node(canvaslayer_path)

	# connect this button's pressed signal to toggle the popup
	if not is_connected("pressed", Callable(self, "_on_pressed")):
		self.connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	if not popup:
		return
	# toggle the popup/container: if visible -> hide, else show
	if popup.visible:
		# hide popup
		if popup.has_method("hide"):
			popup.hide()
		else:
			popup.visible = false
		# also hide canvaslayer if present
		if canvaslayer:
			if canvaslayer.has_method("hide"):
				canvaslayer.hide()
			else:
				canvaslayer.visible = false
	else:
		# show popup (prefer popup_centered)
		if popup.has_method("popup_centered"):
			popup.popup_centered()
		else:
			popup.visible = true
		# also show canvaslayer if present
		if canvaslayer:
			if canvaslayer.has_method("show"):
				canvaslayer.show()
			else:
				canvaslayer.visible = true

func _on_yes_pressed():
	# yes: go back to main menu
	GameController.set_phase(GameController.GamePhase.PRE_GAME)

func _on_no_pressed():
	if not popup:
		return
	# no: close the container/popup and hide canvaslayer
	if popup.has_method("hide"):
		popup.hide()
	else:
		popup.visible = false
	if canvaslayer:
		if canvaslayer.has_method("hide"):
			canvaslayer.hide()
		else:
			canvaslayer.visible = false
